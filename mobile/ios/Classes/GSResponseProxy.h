//
//  GSResponseProxy.h
//  gigya
//
//  Created by Paul Mietz Egli on 11/25/13.
//
//

#import "TiProxy.h"

@class GSResponse;

@interface GSResponseProxy : TiProxy

+ (instancetype)proxyWithGSResponse:(GSResponse *)response;

+ (NSDictionary *)dictionaryWithGSResponse:(GSResponse *)response;

@end
