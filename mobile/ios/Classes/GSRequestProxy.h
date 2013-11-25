//
//  GSRequestProxy.h
//  gigya
//
//  Created by Paul Mietz Egli on 11/25/13.
//
//

#import "TiProxy.h"

@class GSRequest;

@interface GSRequestProxy : TiProxy

+ (instancetype)proxyWithGSRequest:(GSRequest *)request;

@end
