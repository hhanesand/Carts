//
//  GLListItem.h
//  GroceryList
//
//  Created by Hakon Hanesand on 4/18/15.

#import <Parse/Parse.h>
#import "GLBarcodeObject.h"

@interface GLListItemObject : PFObject<PFSubclassing>

@property (nonatomic) GLBarcodeObject *item;
@property (nonatomic) NSNumber *quantity;

+ (instancetype)objectWithBarcodeObject:(GLBarcodeObject *)barcodeObject;

@end
