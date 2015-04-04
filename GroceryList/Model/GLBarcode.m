//
//  GLBarcode.m
//  GroceryList
//
//  Created by Hakon Hanesand on 3/10/15.
//
//

#import "GLBarcode.h"

@implementation GLBarcode

+ (GLBarcode *)barcodeWithBarcode:(NSString *)barcode {
    GLBarcode *item = [[GLBarcode alloc] init];
    item.barcode = barcode;
    return item;
}

+ (GLBarcode *)barcodeWithMetadataObject:(AVMetadataMachineReadableCodeObject *)object {
    GLBarcode *barcode = [[GLBarcode alloc] init];
    barcode.barcode = object.stringValue;
    barcode.type = object.type;
    return barcode;
}

@end
