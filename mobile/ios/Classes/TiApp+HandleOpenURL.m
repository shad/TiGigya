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
    [launchOptions removeObjectForKey:UIApplicationLaunchOptionsURLKey];
    [launchOptions setObject:[url absoluteString] forKey:@"url"];
    [launchOptions removeObjectForKey:UIApplicationLaunchOptionsSourceApplicationKey];
    [launchOptions setObject:sourceApplication forKey:@"source"];
    return [Gigya handleOpenURL:url
              sourceApplication:sourceApplication
                     annotation:annotation];
}

@end
