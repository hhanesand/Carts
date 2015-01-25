//
//  GLBarcodeDatabase.h
//  GroceryList
//
//  Created by Hakon Hanesand on 1/23/15.
//
//

#import "GLBarcodeManager.h"

typedef enum GLBarcodeDatabaseReturnType {
    GLBarcodeDatabaseJSON,
    GLBarcodeDatabaseHTLM
} GLBarcodeDatabaseReturnType;

@interface GLBarcodeDatabase : NSObject

@property (nonatomic) NSString *url;
@property (nonatomic) GLBarcodeDatabaseReturnType returnType;
@property (nonatomic, copy) NSRange (^searchBlock)(NSString *,NSString *);
@property (nonatomic, copy) NSString *(^barcodeBlock)(NSString *);

- (instancetype)initWithNameOfDatabase:(NSString *)url returnType:(GLBarcodeDatabaseReturnType)returnType andSearchBlock:(NSRange (^)(NSString *string, NSString *barcode))searchBlock;

- (instancetype)initWithNameOfDatabase:(NSString *)url returnType:(GLBarcodeDatabaseReturnType)returnType searchBlock:(NSRange (^)(NSString *string, NSString *barcode))searchBlock andBarcodeModifier:(NSString * (^)(NSString *barcode))barcodeBlock ;

- (NSString *)getURLForDatabaseWithBarcode:(NSString *)barcode;

@end