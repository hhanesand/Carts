//
//  GLUser.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/18/15.

#import <Parse/PFSubclassing.h>

#import "GLUser.h"

@implementation GLUser

@dynamic list;

+ (instancetype)currentUser {
    PFUser *user = [super currentUser];
    return (GLUser *)user;
}

@end
