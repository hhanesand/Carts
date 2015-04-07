//
//  GLListItem.h
//  GroceryList
//
//  Created by Hakon Hanesand on 2/19/15.

#import <Parse/Parse.h>

@class GLBarcodeObject;

/**
 *  Parse object that reflect the "list" class in Parse. This class stores a pointer to a barcode object (GLBarcodeObject), its owner, and a list of user modifications
 *  This allows us to store a list of scannable items in class on parse, and then in this class we can track any changes that the user has made to the item. (ie we can share the list
 *  scannable items among all users, and store changes here)
 */
@interface GLListObject : PFObject<PFSubclassing>

@property (nonatomic) GLBarcodeObject *item;
@property (nonatomic) PFUser *owner;
@property (nonatomic) NSMutableDictionary *userModifications;

+ (instancetype)objectWithCurrentUserAndBarcodeItem:(GLBarcodeObject *)barcodeItem;
+ (instancetype)objectWithCurrentUser;

- (void)addUserModification:(NSString *)value forKey:(NSString *)key;

- (NSString *)getName;
- (NSString *)getCategory;
- (NSString *)getBrand;
- (NSString *)getManufacturer;

@end
