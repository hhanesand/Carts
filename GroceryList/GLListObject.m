//
//  GLListItem.m
//  GroceryList
//
//  Created by Hakon Hanesand on 2/19/15.
//
//

#import "GLListObject.h"

@implementation GLListObject

@dynamic item;
@dynamic owner;
@dynamic userModifications;

+ (instancetype)objectWithCurrentUserAndBarcodeItem:(GLBarcodeObject *)barcodeItem {
    GLListObject *new = [GLListObject objectWithCurrentUser];
    new.item = barcodeItem;
    return new;
}

+ (instancetype)objectWithCurrentUser {
    GLListObject *new = [GLListObject object];
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
