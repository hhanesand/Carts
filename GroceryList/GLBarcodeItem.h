//
//  GLBarcodeItem.h
//  GroceryList
//
//  Created by Hakon Hanesand on 2/9/15.
//
//

#import <Foundation/Foundation.h>
#import "GLBarcodeItemDelegate.h"
#import "Parse/Parse.h"

@interface GLBarcodeItem : PFObject<PFSubclassing>

@property (nonatomic) id<GLBarcodeItemDelegate> delegate;

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *upc;
@property (nonatomic) NSString *brand;
@property (nonatomic) NSString *category;
@property (nonatomic) NSString *manufacturer;
@property (nonatomic) NSString *upc_e;
@property (nonatomic) NSString *ean13;
@property (nonatomic) NSMutableArray *image;

@property (nonatomic) BOOL wasGeneratedLocally;
@property (nonatomic) NSData *imageData;

+ (NSString *)parseClassName;
+ (instancetype)objectWithData:(NSDictionary *)data;

@end