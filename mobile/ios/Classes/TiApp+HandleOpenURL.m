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
    NSLog(@"[INFO] openURL");
    return [Gigya handleOpenURL:url
              sourceApplication:sourceApplication
                     annotation:annotation];
}

@end
