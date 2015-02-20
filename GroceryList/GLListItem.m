//
//  GLListItem.m
//  GroceryList
//
//  Created by Hakon Hanesand on 2/19/15.
//
//

#import "GLListItem.h"

@implementation GLListItem

@synthesize wasGeneratedLocally;

@dynamic item;
@dynamic owner;

+ (instancetype)objectWithCurrentUser {
    GLListItem *new = [GLListItem object];
    new.owner = [PFUser currentUser];
    return new;
}

+ (NSString *)parseClassName {
    return @"list";
}

+ (void)load {
    [self registerSubclass];
}

@end
