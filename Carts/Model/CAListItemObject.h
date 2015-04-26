//
//  CAListItem.h
//  GroceryList
//
//  Created by Hakon Hanesand on 4/18/15.

#import <Parse/Parse.h>
#import "CABarcodeObject.h"

@interface CAListItemObject : PFObject<PFSubclassing>

@property (nonatomic) CABarcodeObject *item;
@property (nonatomic) NSNumber *quantity;

+ (instancetype)objectWithBarcodeObject:(CABarcodeObject *)barcodeObject;

@end
