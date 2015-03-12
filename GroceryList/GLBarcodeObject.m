//
//  GLBarcodeItem.m
//  GroceryList
//
//  Created by Hakon Hanesand on 2/9/15.
//
//

#import "GLBarcodeObject.h"
#import <Parse/PFObject+Subclass.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <AVFoundation/AVFoundation.h>
#import "GLBarcode.h"

@implementation GLBarcodeObject

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

+ (void)load {
    [self registerSubclass];
}

+ (GLBarcodeObject *)objectWithBarcode:(GLBarcode *)item {
    GLBarcodeObject *object = [GLBarcodeObject object];
    [object setObject:[NSArray arrayWithObject:item.barcode] forKey:@"barcodes"];
    [object setObject:[NSArray arrayWithObject:item.type] forKey:@"types"];
    return object;
}

+ (GLBarcodeObject *)objectWithDictionary:(NSDictionary *)data {
    GLBarcodeObject *object = [GLBarcodeObject object];
    for (NSString *key in [data allKeys]) {
        [object setObject:data[key] forKey:key];
    }
    
    return object;
}


- (NSString *)getFirstBarcode {
    return [self.barcodes firstObject];
}

- (NSString *)description {
    NSMutableString *string = [NSMutableString stringWithString:self.name];
    [string appendString:[@" barcodes " stringByAppendingString:[self.barcodes description]]];
    #warning stop gap bug fix
    //[string appendString:[@" types " stringByAppendingString:[self.types description]]];
    
    if (self.image && [self.image count] > 0) {
        [string appendString:@" | "];
        [string appendString:self.image[0]];
    }
    
    return [string description];
}

- (void)addImageURLSFromArray:(NSArray *)array {
    if (self.image) {
        [self.image addObjectsFromArray:array];
    } else {
        NSLog(@"Creating a new array");
        self.image = [NSMutableArray new];
        [self.image addObjectsFromArray:array];
    }
}

@end