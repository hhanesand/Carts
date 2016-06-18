//
//  CAListItem.m
//  Carts
//
//  Created by Hakon Hanesand on 4/18/15.

#import <Parse/PFObject+Subclass.h>

#import "CAListItemObject.h"

@implementation CAListItemObject

@dynamic item;
@dynamic quantity;

+ (instancetype)objectWithBarcodeObject:(CABarcodeObject *)barcodeObject {
    CAListItemObject *object = [super object];
    object.item = barcodeObject;
    object.quantity = @(1);
    return object;
}

+ (NSString *)parseClassName {
    return @"listItem";
}

@end
