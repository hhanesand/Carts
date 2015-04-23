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

+ (PFUser *)user {
    GLUser *user = (GLUser *)[super user];
    user.list = [GLListObject object];
    return user;
}

+ (instancetype)object {
    return [super object];
}

+ (PFQuery *)query {
    return [super query];
}

+ (GLUser *)GL_currentUser {
    return [super currentUser];
}

+ (BOOL)isLoggedIn {
    return ![PFAnonymousUtils isLinkedWithUser:[super currentUser]];
}

- (NSString *)bestName {
    if([GLUser GL_currentUser] == self) {
        return @"Your Cart";
    } else {
        return [self.username stringByAppendingString:@"'s Cart"];
    }
}

@end
