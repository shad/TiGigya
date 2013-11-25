//
//  GSResponseProxy.m
//  gigya
//
//  Created by Paul Mietz Egli on 11/25/13.
//
//

#import "GSResponseProxy.h"
#import "GSResponse.h"

@interface GSResponseProxy ()
@property (nonatomic, strong) GSResponse * response;
@end

@implementation GSResponseProxy

+ (instancetype)proxyWithGSResponse:(GSResponse *)response {
    return response ? [[[self alloc] initWithGSResponse:response] autorelease] : [NSNull null];
}

+ (NSDictionary *)dictionaryWithGSResponse:(GSResponse *)response {
    NSMutableDictionary * result = [NSMutableDictionary dictionary];
    for (NSString * key in response.allKeys) {
        [result setObject:[response objectForKey:key] forKey:key];
    }
    return result;
}

- (instancetype)initWithGSResponse:(GSResponse *)response {
    if (self = [super init]) {
        self.response = response;
    }
    return self;
}



@end
