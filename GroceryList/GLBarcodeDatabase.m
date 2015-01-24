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
    if (self = [super init]) {
        self.url = url;
        self.returnType = returnType;
        self.searchBlock = searchBlock;
    }
    
    return self;
}

- (NSString *)getURLForDatabaseWithBarcode:(NSString *)barcode {
    return [self.url stringByReplacingOccurrencesOfString:@"%@" withString:barcode];
}

@end
