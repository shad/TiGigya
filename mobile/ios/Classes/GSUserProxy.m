//
//  GSUserProxy.m
//  gigya
//
//  Created by Paul Mietz Egli on 11/22/13.
//
//

#import "GSUserProxy.h"
#import "GSUser.h"

@interface GSUserProxy ()
@property (nonatomic, strong) GSUser * user;
@end

@implementation GSUserProxy

+ (instancetype)proxyWithGSUser:(GSUser *)user {
    return user ? [[[self alloc] initWithGSUser:user] autorelease] : [NSNull null];
}

+ (NSDictionary *)dictionaryWithGSUser:(GSUser *)user {
    if (!user) return nil;
    
    return @{
             @"UID": user.UID,
             @"loginProvider": user.loginProvider,
             @"nickname": user.nickname,
             @"firstName": user.firstName,
             @"lastName": user.lastName,
             @"email": user.email,
             @"identities": user.identities,
             @"photoURL": [user.photoURL absoluteString],
             @"thumbnailURL": [user.thumbnailURL absoluteString]
             };
}

- (instancetype)initWithGSUser:(GSUser *)user {
    if (self = [super init]) {
        self.user = user;
    }
    return self;
}

- (id)UID {
    return self.user.UID;
}

- (id)loginProvider {
    return self.user.loginProvider;
}

- (id)nickname {
    return self.user.nickname;
}

- (id)firstName {
    return self.user.firstName;
}

- (id)lastName {
    return self.user.lastName;
}

- (id)email {
    return self.user.email;
}

- (id)identities {
    // TODO
    return nil;
}

- (id)photoURL {
    return [self.user.photoURL absoluteString];
}

- (id)thumbnailURL {
    return [self.user.thumbnailURL absoluteString];
}

@end
