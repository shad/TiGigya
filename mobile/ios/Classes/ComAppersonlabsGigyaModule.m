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

#import "Gigya.h"

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
    });
}

-(void)showLoginProvidersDialog:(id)args {
    NSDictionary * dict;
    
    ENSURE_ARG_AT_INDEX(dict, args, 0, NSDictionary)
    
    NSLog(@"[INFO] showLoginProvidersDialog: %@", dict);
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
