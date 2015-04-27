//
//  CABarcodeItem.h
//  GroceryList
//
//  Created by Hakon Hanesand on 2/9/15.

#import <Parse/Parse.h>

#import "CABarcodeScannerDelegate.h"

@class AVMetadataMachineReadableCodeObject;

/**
 *  A Parse object subclass that stores information about a barcode object
 */
@interface CABarcodeObject : PFObject<PFSubclassing>

/**
 *  The name of the item
 */
@property (nonatomic, copy) NSString *name;

/**
 *  The brand of the item
 */
@property (nonatomic, copy) NSString *brand;

/**
 *  The category of item (ie Dairy/Snacks/Dinner...)
 */
@property (nonatomic, copy) NSString *category;

/**
 *  The manufacturer of this item
 */
@property (nonatomic, copy) NSString *manufacturer;

/**
 *  The barcodes that point to this item, may be several different versions of similar barcodes (NSStrings)
 */
@property (nonatomic) NSMutableArray *barcodes;

/**
 *  A parallel array with the barcodes array. Stores the type of barcode scanned in NSStrings
 */
@property (nonatomic) NSMutableArray *types;

/**
 *  A list of URLs to images from bing or factual (NSStrings)
 */
@property (nonatomic) NSMutableArray *image;

/**
 *  Initializers
 */
+ (CABarcodeObject *)objectWithBarcode:(CABarcode *)barcode;
+ (CABarcodeObject *)objectWithDictionary:(NSDictionary *)data;
+ (CABarcodeObject *)objectWithName:(NSString *)barcode;

- (void)addImageURLSFromArray:(NSArray *)array;
@end