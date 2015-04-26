//
//  GLBarcode.h
//  GroceryList
//
//  Created by Hakon Hanesand on 3/10/15.

@import Foundation;
@import AVFoundation;

/**
 *  Light wrapper class that extracts data from AVFoundation
 */
@interface GLBarcode : NSObject

/**
 *  Construct a barcode object with a barcode
 *
 *  @param barcode The barcode of the object scanned
 *
 *  @return A new barcode object
 */
+ (GLBarcode *)barcodeWithBarcode:(NSString *)barcode;

/**
 *  Construct a barcode object with an AVMetadataMachineReadableCodeObject
 *
 *  @param object The AVMetadataMachineReadableCodeObject
 *
 *  @return An new barcode object
 */
+ (GLBarcode *)barcodeWithMetadataObject:(AVMetadataMachineReadableCodeObject *)object;

/**
 *  The barcode of the item
 */
@property (nonatomic) NSString *barcode;

/**
 *  The type of barcode that was scanned (ie UPC/EAN13...)
 */
@property (nonatomic) NSString *type;

@end
