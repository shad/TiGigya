//
//  GSSessionProxy.h
//  gigya
//
//  Created by Paul Mietz Egli on 11/22/13.
//
//

#import "TiProxy.h"

@class GSSession;

@interface GSSessionProxy : TiProxy

+ (instancetype)proxyWithGSSession:(GSSession *)session;

@end
