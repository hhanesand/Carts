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

+ (instancetype)currentUser {
    PFUser *user = [super currentUser];
    return (GLUser *)user;
}

@end
