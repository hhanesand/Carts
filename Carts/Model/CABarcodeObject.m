//
//  CABarcodeItem.m
//  GroceryList
//
//  Created by Hakon Hanesand on 2/9/15.

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <Parse/PFObject+Subclass.h>

#import "CABarcodeObject.h"
#import "CABarcode.h"

@import AVFoundation;

@implementation CABarcodeObject

@dynamic name;
@dynamic barcodes;
@dynamic types;
@dynamic brand;
@dynamic category;
@dynamic manufacturer;
@dynamic image;

+ (NSString *)parseClassName {
    return @"item";
}

+ (CABarcodeObject *)objectWithBarcode:(CABarcode *)item {
    CABarcodeObject *object = [CABarcodeObject object];
    [object setObject:[NSArray arrayWithObject:item.barcode] forKey:@"barcodes"];
    [object setObject:[NSArray arrayWithObject:item.type] forKey:@"types"];
    return object;
}

+ (CABarcodeObject *)objectWithDictionary:(NSDictionary *)data {
    CABarcodeObject *object = [CABarcodeObject object];
    
    for (NSString *key in [data allKeys]) {
        [object setObject:data[key] forKey:key];
    }
    
    return object;
}

+ (CABarcodeObject *)objectWithName:(NSString *)name {
    CABarcodeObject *object = [CABarcodeObject object];
    object.name = name;
    return object;
}


- (NSString *)getFirstBarcode {
    return [self.barcodes firstObject];
}

- (NSString *)description {
    NSMutableString *string = [NSMutableString stringWithString:self.name];
//    [string appendString:[@" barcodes " stringByAppendingString:[self.barcodes description]]];
    //[string appendString:[@" types " stringByAppendingString:[self.types description]]];
    
    if ([self.image count] > 0) {
        [string appendString:@" | "];
        [string appendString:self.image[0]];
    }
    
    return [string description];
}

- (void)addImageURLSFromArray:(NSArray *)array {
    if (self.image) {
        NSMutableArray *combinedArray = [NSMutableArray arrayWithArray:array];
        [combinedArray addObjectsFromArray:self.image];
        
        [self setObject:combinedArray forKey:@"image"];
    } else {
        self.image = [NSMutableArray arrayWithArray:array];
    }
}

@end
