//
//  GLBarcodeDatabase.m
//  GroceryList
//
//  Created by Hakon Hanesand on 1/23/15.
//
//

#import "GLBarcodeDatabase.h"

@implementation GLBarcodeDatabase

- (instancetype)initWithURLOfDatabase:(NSString *)url withName:(NSString *)name andPath:(NSString *)path {
    if (self = [super init]) {
        self.url = url;
        self.name = name;
        self.path = path;
    }
    
    return self;
}

- (NSString *)getURLForDatabaseWithBarcode:(NSString *)barcode {
    return [self.url stringByReplacingOccurrencesOfString:@"%@" withString:barcode];
}

@end
