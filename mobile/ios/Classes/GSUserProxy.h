//
//  GSUserProxy.h
//  gigya
//
//  Created by Paul Mietz Egli on 11/22/13.
//
//

#import "TiProxy.h"

@class GSUser;

@interface GSUserProxy : TiProxy

+ (instancetype)proxyWithGSUser:(GSUser *)user;

@end
