//
//  GLBarcodeItem.m
//  GroceryList
//
//  Created by Hakon Hanesand on 2/9/15.
//
//

#import "GLBarcodeItem.h"

@implementation GLBarcodeItem

static NSString *notificationName = @"barcodeItemUpdated";

+ (NSString *)notificationName {
    return notificationName;
}

- (instancetype)initWithBarcode:(NSString *)barcode name:(NSString *)name {
    if (self = [super init]) {
        self.barcode = barcode;
        self.name = name;
    }
    
    return self;
}

- (void)fetchPictureWithURL:(NSString *)urlString {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *url = [NSURL URLWithString:urlString];
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageData = data;
            NSLog(@"Finished downloading picture sending notification");
            [[NSNotificationCenter defaultCenter] postNotificationName:[GLBarcodeItem notificationName] object:nil];
        });
    });
}

- (NSString *)description {
    return [self.barcode stringByAppendingString:[@" | "  stringByAppendingString:self.name]];
}

@end
