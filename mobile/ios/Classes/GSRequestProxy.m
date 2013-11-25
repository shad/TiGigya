//
//  GSRequestProxy.m
//  gigya
//
//  Created by Paul Mietz Egli on 11/25/13.
//
//

#import "GSRequestProxy.h"
#import "GSRequest.h"
#import "GSResponseProxy.h"

@interface GSRequestProxy ()
@property (nonatomic, strong) GSRequest * request;
@end

@implementation GSRequestProxy

+ (instancetype)proxyWithGSRequest:(GSRequest *)request {
    return request ? [[[self alloc] initWithGSRequest:request] autorelease] : [NSNull null];
}

- (instancetype)initWithGSRequest:(GSRequest *)request {
    if (self = [super init]) {
        self.request = request;
    }
    return self;
}

#pragma mark Properties

- (void)setParameters:(id)value {
    self.request.parameters = value;
}

- (id)method {
    return self.request.method;
}

- (void)setMethod:(id)value {
    self.request.method = value;
}

- (id)useHTTPS {
    return NUMBOOL(self.request.useHTTPS);
}

- (void)setUseHTTPS:(id)value {
    self.request.useHTTPS = [value boolValue];
}

#pragma mark Sending

- (void)sendAsync:(id)args {
    ENSURE_UI_THREAD_1_ARG(args)
    
    NSDictionary * dict;
    
    ENSURE_ARG_AT_INDEX(dict, args, 0, NSDictionary)
    
    KrollCallback * success = [dict objectForKey:@"success"];
    KrollCallback * failure = [dict objectForKey:@"failure"];

    [self.request sendWithResponseHandler:^(GSResponse *response, NSError *error) {
        if (!error) {
            NSDictionary * params = @{ @"response": [GSResponseProxy dictionaryWithGSResponse:response]};
            [success call:@[params] thisObject:nil];
        }
        else {
            NSDictionary * params = @{ @"code": [NSNumber numberWithInteger:error.code], @"error": error.description };
            [failure call:@[params] thisObject:nil];
        }
    }];
}

- (id)sendSync:(id)args {
    NSError * error = nil;
    
    GSResponse * response = [self.request sendSynchronouslyWithError:&error];
    if (!error) {
        return [GSResponseProxy dictionaryWithGSResponse:response];
    }
    else {
        return @{ @"code": [NSNumber numberWithInteger:error.code], @"error": error.description };
    }
}

@end
