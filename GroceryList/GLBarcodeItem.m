//
//  GLBarcodeItem.m
//  GroceryList
//
//  Created by Hakon Hanesand on 2/9/15.
//
//

#import "GLBarcodeItem.h"
#import <Parse/PFObject+Subclass.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <AVFoundation/AVFoundation.h>

@implementation GLBarcodeItem

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

+ (instancetype)objectWithMetadataObject:(AVMetadataMachineReadableCodeObject *)metadata {
    GLBarcodeItem *object = [super object];
    [object.types addObject:metadata.type];
    [object.barcodes addObject:metadata.stringValue];
    return object;
}

- (NSString *)getFirstBarcode {
    return [self.barcodes firstObject];
}

- (void)loadJSONData:(NSDictionary *)data {
    for (NSString *key in [data allKeys]) {
        [self setObject:data[key] forKey:key];
    }
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
