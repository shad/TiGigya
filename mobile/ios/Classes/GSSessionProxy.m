//
//  GSSessionProxy.m
//  gigya
//
//  Created by Paul Mietz Egli on 11/22/13.
//
//

#import "GSSessionProxy.h"
#import "GSSession.h"

@interface GSSessionProxy ()
@property (nonatomic, strong) GSSession * session;
@end

@implementation GSSessionProxy

+ (instancetype)proxyWithGSSession:(GSSession *)session {
    return session ? [[[self alloc] initWithGSSession:session] autorelease] : [NSNull null];
}

+ (NSDictionary *)dictionaryWithGSSession:(GSSession *)session {
    if (!session) return nil;
    
    return @{
             @"token": session.token,
             @"secret": session.secret,
             @"expiration": session.expiration,
             @"lastLoginProvider": session.lastLoginProvider,
             @"isValid": NUMBOOL(session.isValid)
             };
}


- (instancetype)initWithGSSession:(GSSession *)session {
    if (self = [super init]) {
        self.session = session;
    }
    return self;
}

- (id)token {
    return self.session.token;
}

- (id)secret {
    return self.session.secret;
}

- (id)expiration {
    return self.session.expiration;
}

- (id)lastLoginProvider {
    return self.session.lastLoginProvider;
}

- (id)isValid {
    return NUMBOOL(self.session.isValid);
}

@end
