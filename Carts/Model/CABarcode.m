//
//  CABarcode.m
//  GroceryList
//
//  Created by Hakon Hanesand on 3/10/15.

#import "CABarcode.h"

@implementation CABarcode

+ (CABarcode *)barcodeWithBarcode:(NSString *)barcode {
    CABarcode *item = [[CABarcode alloc] init];
    item.barcode = barcode;
    return item;
}

+ (CABarcode *)barcodeWithMetadataObject:(AVMetadataMachineReadableCodeObject *)object {
    CABarcode *barcode = [[CABarcode alloc] init];
    barcode.barcode = object.stringValue;
    barcode.type = object.type;
    return barcode;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@", self.barcode];
}

@end
