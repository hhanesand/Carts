//
//  GLListItem.m
//  GroceryList
//
//  Created by Hakon Hanesand on 2/19/15.

#import "GLListObject.h"
#import "GLBarcodeObject.h"
#import <Parse/PFObject+Subclass.h>

@implementation GLListObject

@dynamic user;
@dynamic item;

+ (NSString *)parseClassName {
    return @"list";
}

+ (instancetype)objectWithCurrentUserAndBarcodeObject:(GLBarcodeObject *)barcodeObject {
    GLListObject *object = [super object];
    object.user = [PFUser currentUser];
    object.item = barcodeObject;
    return object;
}

@end
