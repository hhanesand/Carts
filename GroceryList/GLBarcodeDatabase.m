//
//  GLBarcodeDatabase.m
//  GroceryList
//
//  Created by Hakon Hanesand on 1/23/15.
//
//

#import "GLBarcodeDatabase.h"

@implementation GLBarcodeDatabase

- (instancetype)initWithNameOfDatabase:(NSString *)url returnType:(GLBarcodeDatabaseReturnType)returnType andSearchBlock:(NSRange (^)(NSString* string, NSString *barcode))searchBlock {
    return [self initWithNameOfDatabase:url returnType:returnType searchBlock:searchBlock andBarcodeModifier:^NSString *(NSString *barcode) {
        return barcode;
    }];
}

- (instancetype)initWithNameOfDatabase:(NSString *)url returnType:(GLBarcodeDatabaseReturnType)returnType searchBlock:(NSRange (^)(NSString * string, NSString * barcode))searchBlock andBarcodeModifier:(NSString * (^)(NSString *barcode))barcodeBlock {
    if (self = [super init]) {
        self.url = url;
        self.returnType = returnType;
        self.searchBlock = searchBlock;
        self.barcodeBlock = barcodeBlock;
    }
    
    return self;
}

- (NSString *)getURLForDatabaseWithBarcode:(NSString *)barcode {
    return [self.url stringByReplacingOccurrencesOfString:@"%@" withString:barcode];
}

@end
