//
//  GLBarcode.h
//  GroceryList
//
//  Created by Hakon Hanesand on 3/10/15.

@import Foundation;
@import AVFoundation;

@interface GLBarcode : NSObject

+ (GLBarcode *)barcodeWithBarcode:(NSString *)barcode;
+ (GLBarcode *)barcodeWithMetadataObject:(AVMetadataMachineReadableCodeObject *)object;

@property (nonatomic) NSString *barcode;
@property (nonatomic) NSString *type;

@end
