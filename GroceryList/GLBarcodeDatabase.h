//
//  GLBarcodeDatabase.h
//  GroceryList
//
//  Created by Hakon Hanesand on 1/23/15.
//
//

#import <Foundation/Foundation.h>
@class GLBarcodeManager;

typedef NS_ENUM(NSInteger, GLBarcodeDatabaseReturnType) {
    GLBarcodeDatabaseJSON,
    GLBarcodeDatabaseHTLM
};

@interface GLBarcodeDatabase : NSObject

@property (nonatomic) NSString *url;
@property (nonatomic) GLBarcodeDatabaseReturnType returnType;
@property (nonatomic, copy) NSRange (^searchBlock)(NSString *,NSString *);
@property (nonatomic, copy) NSString *(^barcodeBlock)(NSString *);

//if GLBarcodeDatabaseReturnT
- (instancetype)initWithNameOfDatabase:(NSString *)url withReturnType:(GLBarcodeDatabaseReturnType)returnType andPath:(NSString *)path andBarcodeModifier:(NSString * (^)(NSString *barcode))barcodeBlock;

- (NSString *)getURLForDatabaseWithBarcode:(NSString *)barcode;

@end