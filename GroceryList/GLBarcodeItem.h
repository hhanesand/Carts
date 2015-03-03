//
//  GLBarcodeItem.h
//  GroceryList
//
//  Created by Hakon Hanesand on 2/9/15.
//
//

#import <Parse/Parse.h>
#import "GLBarcodeScannerDelegate.h"

@class AVMetadataMachineReadableCodeObject;

@interface GLBarcodeItem : PFObject<PFSubclassing>

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *brand;
@property (nonatomic) NSString *category;
@property (nonatomic) NSString *manufacturer;

@property (nonatomic) NSMutableArray *barcodes;
@property (nonatomic) NSMutableArray *types;

@property (nonatomic) NSMutableArray *image;

+ (NSString *)parseClassName;
+ (instancetype)objectWithMetadataObject:(AVMetadataMachineReadableCodeObject *)object;

- (NSString *)getFirstBarcode;

- (void)loadJSONData:(NSDictionary *)data;
- (void)addImageURLSFromArray:(NSArray *)array;
@end