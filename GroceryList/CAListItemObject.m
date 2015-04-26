//
//  GLListItem.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/18/15.

#import <Parse/PFObject+Subclass.h>

#import "GLListItemObject.h"

@implementation GLListItemObject

@dynamic item;
@dynamic quantity;

+ (instancetype)objectWithBarcodeObject:(GLBarcodeObject *)barcodeObject {
    GLListItemObject *object = [super object];
    object.item = barcodeObject;
    object.quantity = @(1);
    return object;
}

+ (NSString *)parseClassName {
    return @"listItem";
}

@end
