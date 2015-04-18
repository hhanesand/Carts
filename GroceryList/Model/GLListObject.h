//
//  GLListItem.h
//  GroceryList
//
//  Created by Hakon Hanesand on 2/19/15.

#import <Parse/Parse.h>

@class GLBarcodeObject;

@interface GLListObject : PFObject<PFSubclassing>

@property (nonatomic) PFUser *user;
@property (nonatomic) GLBarcodeObject *item;

+ (instancetype)objectWithCurrentUserAndBarcodeObject:(GLBarcodeObject *)barcodeObject;

@end
