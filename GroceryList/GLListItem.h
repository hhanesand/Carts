//
//  GLListItem.h
//  GroceryList
//
//  Created by Hakon Hanesand on 2/19/15.
//
//

#import <Parse/Parse.h>

@class GLBarcodeItem;

@interface GLListItem : PFObject<PFSubclassing>

@property (nonatomic) GLBarcodeItem *item;
@property (nonatomic) PFUser *owner;

@property (nonatomic) BOOL wasGeneratedLocally;

+ (instancetype)objectWithCurrentUser;

@end
