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
        self.url = url;
    }
    
    return self;
}

- (instancetype)initWithBarcode:(NSString *)barcode name:(NSString *)name {
    return [self initWithBarcode:barcode name:name andPictureURL:@""];
}

- (NSURL *)getURLForPicture {
    return [NSURL URLWithString:self.url];
}

@end
