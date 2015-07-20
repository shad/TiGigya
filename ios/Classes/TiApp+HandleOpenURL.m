//
//  TiApp+HandleOpenURL.m
//  gigya
//
//  Created by Paul Mietz Egli on 11/24/13.
//
//

#import "TiApp+HandleOpenURL.h"
#import "Gigya.h"

@implementation TiApp (HandleOpenURL)

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    // THIS IS COPIED FROM TiApp!
    [launchOptions removeObjectForKey:UIApplicationLaunchOptionsURLKey];
    [launchOptions setObject:[url absoluteString] forKey:@"url"];
    [launchOptions removeObjectForKey:UIApplicationLaunchOptionsSourceApplicationKey];
    if(sourceApplication == nil) {
        [launchOptions setObject:[NSNull null] forKey:@"source"];
    } else {
        [launchOptions setObject:sourceApplication forKey:@"source"];
    }
    
    NSLog(@"[GIGYA] handleOpenURL %@",url);

    BOOL wasHandled = [Gigya handleOpenURL:url
                               application:application
                         sourceApplication:sourceApplication
                                annotation:annotation];
    if (wasHandled)
        return NO;
}

@end
