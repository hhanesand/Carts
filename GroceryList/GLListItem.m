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
@dynamic userModifications;

+ (instancetype)objectWithCurrentUserAndBarcodeItem:(GLBarcodeItem *)barcodeItem {
    GLListItem *new = [GLListItem objectWithCurrentUser];
    new.item = barcodeItem;
    return new;
}

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
