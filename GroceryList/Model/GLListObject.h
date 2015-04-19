//
//  GLListItem.h
//  GroceryList
//
//  Created by Hakon Hanesand on 2/19/15.

#import <Parse/Parse.h>

@class GLBarcodeObject;

@interface GLListObject : PFObject<PFSubclassing>

@property (nonatomic) NSMutableArray *items;

@end
