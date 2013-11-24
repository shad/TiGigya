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

@implementation ComAppersonlabsGigyaModule

#pragma mark Internal

-(id)moduleGUID {
	return @"73e1497d-8226-4d81-8a41-823fcfab3a96";
}

-(NSString*)moduleId {
	return @"com.appersonlabs.gigya";
}

#pragma mark Lifecycle

-(void)startup {
	[super startup];
	
	NSLog(@"[INFO] %@ loaded",self);
}

-(void)shutdown:(id)sender {
	[super shutdown:sender];
}

#pragma mark -
#pragma mark Authentication

-(void)setAPIKey:(id)arg {
    ENSURE_STRING(arg)

    // Gigya docs say to only call this once
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [Gigya initWithAPIKey:arg];
        NSLog(@"[INFO] initialized Gigya");
    });
}

- (id)session {
    NSLog(@"[INFO] session: %@",[Gigya session]);
    return [GSSessionProxy proxyWithGSSession:[Gigya session]];
}

-(void)showLoginProvidersDialog:(id)args {
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
                              NSLog(@"[INFO] completion: user=%@, error=%@", user, error);
                              if (!error) {
                                  NSDictionary * params = @{ @"user": [GSUserProxy proxyWithGSUser:user]};
                                  [success call:@[params] thisObject:nil];
                              }
                              else {
                                  NSDictionary * params = @{ @"code": [NSNumber numberWithInteger:error.code], @"error": error.description };
                                  [failure call:@[params] thisObject:nil];
                              }
                          }
         ];
    }
}

-(void)loginToProvider:(id)args {
    
}

-(void)logout:(id)args {
    
}

#pragma mark Connections

-(void)showAddConnectionProvidersDialog:(id)args {
    
}

#pragma mark Requests

-(id)requestForMethod:(id)args {
    return nil;
}

@end
