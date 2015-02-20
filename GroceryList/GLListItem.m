//
//  GLListItem.m
//  GroceryList
//
//  Created by Hakon Hanesand on 2/19/15.
//
//

#import "GLListItem.h"

@implementation GLListItem

@dynamic item;
@dynamic owner;

+ (NSString *)parseClassName {
    return @"list";
}

+ (void)load {
    [self registerSubclass];
}

@end
