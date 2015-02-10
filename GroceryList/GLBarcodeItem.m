//
//  GLBarcodeItem.m
//  GroceryList
//
//  Created by Hakon Hanesand on 2/9/15.
//
//

#import "GLBarcodeItem.h"

@implementation GLBarcodeItem

- (instancetype)initWithBarcode:(NSString *)barcode name:(NSString *)name andPictureURL:(NSString *)url {
    if (self = [super init]) {
        self.barcode = barcode;
        self.name = name;
        
        [self fetchPictureWithURL:url];
    }
    
    return self;
}

- (instancetype)initWithBarcode:(NSString *)barcode name:(NSString *)name {
    return [self initWithBarcode:barcode name:name andPictureURL:@""];
}

- (void)fetchPictureWithURL:(NSString *)urlString {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *url = [NSURL URLWithString:urlString];
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageData = data;
            [self.delegate didFinishLoadingImageForBarcodeItem:self];
            NSLog(@"Image data loaded");
        });
    });
}

- (NSString *)description {
    return [self.barcode stringByAppendingString:[@" | "  stringByAppendingString:self.name]];
}

@end
