/**
 * (c) 2013 Apperson Labs
 *
 * Appcelerator Titanium is Copyright (c) 2009-2010 by Appcelerator, Inc.
 * and licensed under the Apache Public License (version 2)
 */
#import "ComAppersonlabsGigyaModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import "TiApp.h"

#import "Gigya.h"

#import "GSUserProxy.h"
#import "GSSessionProxy.h"
#import "GSRequestProxy.h"
#import "GSResponseProxy.h"

@interface ComAppersonlabsGigyaModule ()
@property (nonatomic, strong) NSMutableDictionary * pendingRequests;
@end

@implementation ComAppersonlabsGigyaModule

#pragma mark Internal

-(id)moduleGUID {
	return @"73e1497d-8226-4d81-8a41-823fcfab3a96";
}

-(NSString*)moduleId {
	return @"com.appersonlabs.gigya";
}

#pragma mark Lifecycle

-(id)init
{
    if (self = [super init])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

-(void)startup {
	[super startup];
	
    self.pendingRequests = [NSMutableDictionary dictionary];
    
	NSLog(@"[INFO] %@ loaded",self);
}

-(void)shutdown:(id)sender {
	[super shutdown:sender];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [super dealloc];
}

-(void)applicationDidBecomeActive:(NSNotification*)note
{
    [Gigya handleDidBecomeActive];
}

#pragma mark -
#pragma mark GSSocalizeDelegate

- (void)userDidLogin:(id)user {
    id obj = user ? @{ @"user": [GSUserProxy dictionaryWithGSUser:user] } : nil;
    [self fireEvent:@"login" withObject:obj];
}

- (void)userDidLogout {
    [self fireEvent:@"logout"];
}

- (void)userInfoDidChange:(id)user {
    id obj = user ? @{ @"user": [GSUserProxy dictionaryWithGSUser:user] } : nil;
    [self fireEvent:@"change" withObject:obj];
}

#pragma mark -
#pragma mark Authentication

- (void)initialize:(NSArray *) args {
    // [args objectAtIndex:1]
    
    
    // Gigya docs say to only call this once
    static dispatch_once_t onceToken;
    
    if ([args objectAtIndex:1]) {
        dispatch_once(&onceToken, ^{
            TiThreadPerformOnMainThread(^{
                [Gigya initWithAPIKey:[TiUtils stringValue:[args objectAtIndex:0]] APIDomain:[TiUtils stringValue:[args objectAtIndex:1]]];
                [Gigya setSocializeDelegate:self];
                NSLog(@"[INFO] initialized Gigya with APIKey and APIDomain");
            }, YES);
        });
    } else {
        dispatch_once(&onceToken, ^{
            TiThreadPerformOnMainThread(^{
                [Gigya initWithAPIKey:[TiUtils stringValue:[args objectAtIndex:0]]];
                [Gigya setSocializeDelegate:self];
                NSLog(@"[INFO] initialized Gigya with APIKey");
            }, YES);
        });
    }
}

- (id)session {
    return [GSSessionProxy proxyWithGSSession:[Gigya session]];
}

- (void)showLoginProvidersDialog:(id)args {
    ENSURE_UI_THREAD_1_ARG(args)
    
    NSDictionary * dict;
    
    ENSURE_ARG_AT_INDEX(dict, args, 0, NSDictionary)

    NSArray * providers = [dict objectForKey:@"providers"];
    if (![providers isKindOfClass:[NSArray class]]) {
        providers = nil;
    }
    
    KrollCallback * success = [dict objectForKey:@"success"];
    KrollCallback * failure = [dict objectForKey:@"failure"];
    
    UIViewController * topController = [[[TiApp app] controller] topContainerController];
    if (topController) {
        [Gigya showLoginProvidersDialogOver:topController
                                  providers:providers
                                 parameters:dict
                          completionHandler:^(GSUser * user, NSError * error) {
                              if (!error && success) {
                                  NSDictionary * params = @{ @"user": [GSUserProxy dictionaryWithGSUser:user] };
                                  [self _fireEventToListener:@"success" withObject:params listener:success thisObject:nil];
                              }
                              if (error && failure) {
                                  NSDictionary * params = @{ @"code": [NSNumber numberWithInteger:error.code], @"error": error.description };
                                  [self _fireEventToListener:@"failure" withObject:params listener:failure thisObject:nil];
                              }
                          }
         ];
    }
}

-(void)loginToProvider:(id)args {
    ENSURE_UI_THREAD_1_ARG(args)

    NSDictionary * dict;
    ENSURE_ARG_AT_INDEX(dict, args, 0, NSDictionary)
    
    NSString * provider = [dict objectForKey:@"name"];
    if (!provider) {
        NSLog(@"[ERROR] missing provider name in loginToProvider");
        return;
    }
    
    KrollCallback * success = [dict objectForKey:@"success"];
    KrollCallback * failure = [dict objectForKey:@"failure"];

    [Gigya loginToProvider:provider parameters:dict completionHandler:^(GSUser *user, NSError *error) {
        if (!error && success) {
            NSDictionary * params = @{ @"user": [GSUserProxy dictionaryWithGSUser:user] };
            [self _fireEventToListener:@"success" withObject:params listener:success thisObject:nil];
        }
        if (error && failure) {
          NSDictionary * params = @{ @"code": [NSNumber numberWithInteger:error.code], @"error": error.description, @"userInfo":error.userInfo };
            [self _fireEventToListener:@"failure" withObject:params listener:failure thisObject:nil];
        }
     }];
}

-(void)loginToProviderOver:(id)args {
    ENSURE_UI_THREAD_1_ARG(args)

    NSDictionary * dict;
    ENSURE_ARG_AT_INDEX(dict, args, 0, NSDictionary)
    
    NSString * provider = [dict objectForKey:@"name"];
    if (!provider) {
        NSLog(@"[ERROR] missing provider name in loginToProvider");
        return;
    }
    
    KrollCallback * success = [dict objectForKey:@"success"];
    KrollCallback * failure = [dict objectForKey:@"failure"];

    UIViewController * topController = [[[TiApp app] controller] topContainerController];

    [Gigya loginToProvider:provider parameters:dict over:topController completionHandler:^(GSUser *user, NSError *error) {
        if (!error && success) {
            NSDictionary * params = @{ @"user": [GSUserProxy dictionaryWithGSUser:user] };
            [self _fireEventToListener:@"success" withObject:params listener:success thisObject:nil];
        }
        if (error && failure) {
          NSDictionary * params = @{ @"code": [NSNumber numberWithInteger:error.code], @"error": error.description, @"userInfo":error.userInfo };
            [self _fireEventToListener:@"failure" withObject:params listener:failure thisObject:nil];
        }
     }];
}

-(void)logout:(id)args {
    ENSURE_UI_THREAD_1_ARG(args)

    NSDictionary * dict;
    ENSURE_ARG_OR_NIL_AT_INDEX(dict, args, 0, NSDictionary)
    
    KrollCallback * success = [dict objectForKey:@"success"];
    KrollCallback * failure = [dict objectForKey:@"failure"];

    [Gigya logoutWithCompletionHandler:^(GSResponse *response, NSError *error) {
        if (!error && success) {
            NSDictionary * params = @{ @"response": [GSResponseProxy dictionaryWithGSResponse:response] };
            [self _fireEventToListener:@"success" withObject:params listener:success thisObject:nil];
        }
        if (error && failure) {
            NSDictionary * params = @{ @"code": [NSNumber numberWithInteger:error.code], @"error": error.description };
            [self _fireEventToListener:@"failure" withObject:params listener:failure thisObject:nil];
        }
    }];
}

#pragma mark Connections

-(void)showAddConnectionProvidersDialog:(id)args {
    ENSURE_UI_THREAD_1_ARG(args)
    
    NSDictionary * dict;
    
    ENSURE_ARG_AT_INDEX(dict, args, 0, NSDictionary)
    
    NSArray * providers = [dict objectForKey:@"providers"];
    if (![providers isKindOfClass:[NSArray class]]) {
        providers = nil;
    }
    
    KrollCallback * success = [dict objectForKey:@"success"];
    KrollCallback * failure = [dict objectForKey:@"failure"];
    
    UIViewController * topController = [[[TiApp app] controller] topContainerController];
    if (topController) {
        [Gigya showAddConnectionProvidersDialogOver:topController
                                          providers:providers
                                         parameters:dict
                                  completionHandler:^(GSUser *user, NSError *error) {
                                      if (!error && success) {
                                          NSDictionary * params = @{ @"user": [GSUserProxy dictionaryWithGSUser:user]};
                                          [self _fireEventToListener:@"success" withObject:params listener:success thisObject:nil];
                                      }
                                      if (error && failure) {
                                          NSDictionary * params = @{ @"code": [NSNumber numberWithInteger:error.code], @"error": error.description };
                                          [self _fireEventToListener:@"failure" withObject:params listener:failure thisObject:nil];
                                      }
                                  }];
    }
}

#pragma mark Requests

/*
- (void)sendRequest:(id)args {
    NSDictionary * dict;
    
    ENSURE_ARG_AT_INDEX(dict, args, 0, NSDictionary)
    
    NSString * method = [dict objectForKey:@"method"];
    if (!method) {
        NSLog(@"[ERROR] missing required parameter: method");
        return;
    }
    
    BOOL async = [dict objectForKey:@"async"] != nil ? [[dict objectForKey:@"async"] boolValue] : YES;
    
    KrollCallback * success = [dict objectForKey:@"success"];
    KrollCallback * failure = [dict objectForKey:@"failure"];
    
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:dict];
    [params removeObjectsForKeys:@[@"method", @"async", @"success", @"failure"]];
    
    NSLog(@"[INFO] parameters are %@", params);
    
    GSRequest * req = [GSRequest requestForMethod:method parameters:params];
    [self.pendingRequests setObject:req forKey:@"req"];
    if (async) {
        NSLog(@"[INFO] sending async");
        [req sendWithResponseHandler:^(GSResponse *response, NSError *error) {
            NSLog(@"[INFO] async returned %@", response);
            if (!error) {
                NSDictionary * params = @{ @"response": [GSResponseProxy dictionaryWithGSResponse:response]};
                [self _fireEventToListener:@"success" withObject:params listener:success thisObject:nil];
            }
            else {
                NSDictionary * params = @{ @"code": [NSNumber numberWithInteger:error.code], @"error": error.description };
                [self _fireEventToListener:@"failure" withObject:params listener:failure thisObject:nil];
            }
        }];
        NSLog(@"[INFO] async sent");
    }
    else {
        NSError * error = nil;
        NSLog(@"[INFO] sending sync");
        GSResponse * response = [req sendSynchronouslyWithError:&error];
        if (!error) {
            NSDictionary * params = @{ @"response": [GSResponseProxy dictionaryWithGSResponse:response]};
            [success call:@[params] thisObject:nil];
        }
        else {
            NSDictionary * params = @{ @"code": [NSNumber numberWithInteger:error.code], @"error": error.description };
            [failure call:@[params] thisObject:nil];
        }
        NSLog(@"[INFO] sending sync returned %@", response);
    }
    
}
*/

-(id)requestForMethod:(id)args {
    NSString * method;
    NSDictionary * parameters;
    
    ENSURE_ARG_AT_INDEX(method, args, 0, NSString)
    ENSURE_ARG_OR_NIL_AT_INDEX(parameters, args, 1, NSDictionary);
    
    return [GSRequestProxy proxyWithGSRequest:[GSRequest requestForMethod:method parameters:parameters]];
}
@end
