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
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

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

#pragma mark Application Lifecycle Overrides
// Doing this at load, this method is only called once per class
+(void)load
{
    static dispatch_once_t onceLoadToken;
    dispatch_once(&onceLoadToken, ^{
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidFinishLaunching:) name:UIApplicationDidFinishLaunchingNotification object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        
    });
}

+(void)applicationDidFinishLaunching:(NSNotification*)note
{
    NSDictionary *launchOptions = [note userInfo];
    UIApplication *application = (UIApplication*)[note object];

    // Load Gigya APIKey and Domian from Info.plist
    NSString *apiKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"TiGigyaAPIKey"];
    NSString *domain = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"TiGigyaDomain"];

    NSLog(@"[INFO] [TiGigya] Init w/ key:%@  domain:%@", apiKey, domain);

    if (domain)
    {
        [Gigya initWithAPIKey:apiKey application:application launchOptions:launchOptions APIDomain:domain];
    }
    else
    {
        [Gigya initWithAPIKey:apiKey application:application launchOptions:launchOptions];
    }
}
+(void)applicationDidBecomeActive:(NSNotification*)note
{
    NSLog(@"[INFO] [TiGigya] Gigya#handleDidBecomeActive");
    [Gigya handleDidBecomeActive];
}


#pragma mark Lifecycle

-(id)init
{
    return self;
}

-(void)startup {
	[super startup];
	
    self.pendingRequests = [NSMutableDictionary dictionary];
    
	NSLog(@"[INFO] [TiGigya] %@ loaded",self);
}

-(void)shutdown:(id)sender {
	[super shutdown:sender];
}

-(void)dealloc
{
    [super dealloc];
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
    // Gigya docs say to only call this once
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        TiThreadPerformOnMainThread(^{
            [Gigya setSocializeDelegate:self];
            NSLog(@"[INFO] [TiGigya] Gigya#setSocializeDelegate");
        }, YES);
    });
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
        NSLog(@"[ERROR] [TiGigya] missing provider name in loginToProvider");
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
        NSLog(@"[ERROR] [TiGigya] missing provider name in loginToProvider");
        return;
    }
    
    KrollCallback * success = [dict objectForKey:@"success"];
    KrollCallback * failure = [dict objectForKey:@"failure"];
    
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[NSNumber numberWithInt:FBSDKLoginBehaviorNative] forKey:@"facebookLoginBehavior"];

    
    UIViewController * topController = [[[TiApp app] controller] topContainerController];

    NSLog(@"[INFO] [TiGigya] Calling loginToProvider:parameters:over:completionHandler params:nil");
    [Gigya loginToProvider:provider
                parameters:params
                      over:topController
         completionHandler:^(GSUser *user, NSError *error) {
             NSLog(@"[INFO] [TiGigya] in completion handler loginToProvider:parameters:over:completionHandler");
             
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
