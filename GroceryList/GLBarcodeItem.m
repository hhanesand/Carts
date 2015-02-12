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

- (void)fetchPicture {
    RACSignal *completionSignal = [RACSignal new];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *data = [NSData dataWithContentsOfURL:self.url];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageData = data;
        });
    });
}

- (NSString *)description {
    NSMutableString *string = [NSMutableString stringWithString:self.name];
    [string appendString:@" | "];
    [string appendString:self.barcode];
    [string appendString:@" | "];
    [string appendString:self.url];
    
    return [string description];
}

@end
