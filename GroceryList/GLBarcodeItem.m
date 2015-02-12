//
//  GLBarcodeItem.m
//  GroceryList
//
//  Created by Hakon Hanesand on 2/9/15.
//
//

#import "GLBarcodeItem.h"
#import <Parse/PFObject+Subclass.h>

@implementation GLBarcodeItem

@synthesize imageData;
@synthesize delegate;

@dynamic barcode;
@dynamic name;
@dynamic url;

static NSString *notificationName = @"barcodeItemUpdated";

+ (NSString *)notificationName {
    return notificationName;
}

+ (NSString *)parseClassName {
    return @"barcodeItem";
}

+ (void)load {
    [self registerSubclass];
}

- (instancetype)initWithBarcode:(NSString *)barcode name:(NSString *)name {
    if (self = [super init]) {

        
        self.barcode = barcode;
        self.name = name;
    }
    
    return self;
}

- (void)fetchPictureWithURL:(NSURL *)url {
    self.url = [url absoluteString];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
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
