//
//  CAListItem.m
//  GroceryList
//
//  Created by Hakon Hanesand on 2/19/15.

#import "CAListObject.h"
#import "CABarcodeObject.h"
#import <Parse/PFObject+Subclass.h>

@implementation CAListObject

@dynamic items;

+ (instancetype)object {
    CAListObject *object = [super object];
    object.items = [NSMutableArray new];
    return object;
}

+ (NSString *)parseClassName {
    return @"list";
}

@end
