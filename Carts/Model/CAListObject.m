//
//  GLListItem.m
//  GroceryList
//
//  Created by Hakon Hanesand on 2/19/15.

#import "GLListObject.h"
#import "GLBarcodeObject.h"
#import <Parse/PFObject+Subclass.h>

@implementation GLListObject

@dynamic items;

+ (instancetype)object {
    GLListObject *object = [super object];
    object.items = [NSMutableArray new];
    return object;
}

+ (NSString *)parseClassName {
    return @"list";
}

@end
