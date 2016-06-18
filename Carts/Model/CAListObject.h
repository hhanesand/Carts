//
//  CAListItem.h
//  Carts
//
//  Created by Hakon Hanesand on 2/19/15.

#import <Parse/Parse.h>

@class CABarcodeObject;

@interface CAListObject : PFObject<PFSubclassing>

@property (nonatomic) NSMutableArray *items;

@end
