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

@dynamic barcode;
@dynamic name;
@dynamic url;

+ (NSString *)parseClassName {
    return @"barcodeItem";
}

+ (void)load {
    [self registerSubclass];
}

- (void)updateWithBarcodeItem:(GLBarcodeItem *)barcodeItem {
    
}

- (NSString *)description {
    NSMutableString *string = [NSMutableString stringWithString:self.name];
    [string appendString:@" | "];
    [string appendString:self.barcode];
    
    if (self.url) {
        [string appendString:@" | "];
        [string appendString:self.url];
    }
    
    return [string description];
}

@end
