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

@implementation GLBarcodeItem

@synthesize imageData;
@synthesize delegate;

@dynamic name;
@dynamic upc;
@dynamic brand;
@dynamic category;
@dynamic manufacturer;
@dynamic upc_e;
@dynamic ean13;
@dynamic image;

+ (NSString *)parseClassName {
    return @"item";
}

+ (void)load {
    [self registerSubclass];
}

- (void)loadJSONData:(NSDictionary *)data {
    for (NSString *key in [data allKeys]) {
        [self setObject:data[key] forKey:key];
    }
}

- (NSString *)description {
    NSMutableString *string = [NSMutableString stringWithString:self.name];
    [string appendString:@" | "];
    [string appendString:self.upc];
    
    NSLog(@"Image array %@", self.image);
    
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
        self.image = [NSMutableArray new];
        [self.image addObjectsFromArray:array];
    }
}

@end
