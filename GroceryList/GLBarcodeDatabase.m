//
//  GLBarcodeDatabase.m
//  GroceryList
//
//  Created by Hakon Hanesand on 1/23/15.
//
//

#import "GLBarcodeDatabase.h"

@implementation GLBarcodeDatabase

- (instancetype)initWithNameOfDatabase:(NSString *)url withReturnType:(GLBarcodeDatabaseReturnType)returnType andPath:(NSString *)path andBarcodeModifier:(NSString * (^)(NSString *barcode))barcodeBlock {
    if (self = [super init]) {
        self.url = url;
        self.returnType = returnType;
        self.path = path;
        self.barcodeBlock = barcodeBlock;
    }
    
    return self;
}

- (instancetype)initWithNameOfDatabase:(NSString *)url withReturnType:(GLBarcodeDatabaseReturnType)returnType andPath:(NSString *)path {
    return [self initWithNameOfDatabase:url withReturnType:returnType andPath:path andBarcodeModifier:^NSString *(NSString *barcode) {
        return barcode;
    }];
}

- (NSString *)getURLForDatabaseWithBarcode:(NSString *)barcode {
    return [self.url stringByReplacingOccurrencesOfString:@"%@" withString:barcode];
}

@end
