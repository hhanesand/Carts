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
@property (nonatomic, copy) NSString *(^barcodeBlock)(NSString *);
@property (nonatomic) NSString *path;

//if GLBarcodeDatabaseReturnType is HTML, the path should be an CSS selector, if it's JSON then it should be the keypath of the node
- (instancetype)initWithNameOfDatabase:(NSString *)url withReturnType:(GLBarcodeDatabaseReturnType)returnType andPath:(NSString *)path andBarcodeModifier:(NSString * (^)(NSString *barcode))barcodeBlock;

- (instancetype)initWithNameOfDatabase:(NSString *)url withReturnType:(GLBarcodeDatabaseReturnType)returnType andPath:(NSString *)path;

- (NSString *)getURLForDatabaseWithBarcode:(NSString *)barcode;

@end