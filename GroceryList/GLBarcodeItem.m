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
@synthesize wasGeneratedLocally;

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

+ (instancetype)objectWithData:(NSDictionary *)data {
    GLBarcodeItem *object = [GLBarcodeItem object];
    
    for (NSString *key in [data allKeys]) {
        [object setObject:data[key] forKey:key];
    }
    
    NSLog(@"New object - %@", object);
    return object;
}

- (NSString *)description {
    NSMutableString *string = [NSMutableString stringWithString:self.name];
    [string appendString:@" | "];
    [string appendString:self.upc];
    
    if (self.image && [self.image count] > 0) {
        [string appendString:@" | "];
        [string appendString:self.image[0]];
    }
    
    return [string description];
}

@end
