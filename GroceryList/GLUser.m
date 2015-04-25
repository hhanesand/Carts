//
//  GLUser.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/18/15.

#import <Parse/PFSubclassing.h>

#import "GLUser.h"

@implementation GLUser

@dynamic list;
@dynamic following;
@dynamic username_lowercase;

+ (PFUser *)user {
    GLUser *user = (GLUser *)[super user];
    user.list = [GLListObject object];
    return user;
}

+ (instancetype)object {
    GLUser *user = [super object];
    user.list = [GLListObject object];
    return user;
}

+ (NSString *)parseClassName {
    return @"_User";
}

+ (PFQuery *)query {
    return [super query];
}

+ (instancetype)currentUser {
    GLUser *cur = [super currentUser];
    
    if (!cur.list) { //fix for automatic user not running +object method
        cur.list = [GLListObject object];;
    }
    
    return cur;
}

+ (BOOL)isLoggedIn {
    return ![PFAnonymousUtils isLinkedWithUser:[super currentUser]];
}

- (NSString *)bestName {
    if([GLUser currentUser] == self) {
        return @"Your Cart";
    } else {
        return [self.username stringByAppendingString:@"'s Cart"];
    }
}

- (void)setUsername:(NSString *)username {
    [super setUsername:username];
    self.username_lowercase = [username lowercaseString];
}

@end
