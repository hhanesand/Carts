//
//  GLBarcodeManager.h
//  GroceryList
//
//  Created by Hakon Hanesand on 1/23/15.
//
//

#import <Foundation/Foundation.h>
#import "GLBarcodeDatabase.h"
#import "ReactiveCocoa/ReactiveCocoa.h"

@interface GLBarcodeManager : NSObject

@property (nonatomic) RACSubject *receiveInternetResponseSignal;

- (void)addBarcodeDatabase:(GLBarcodeDatabase *)database;

- (void)addBarcodeDatabaseWithURL:(NSString *)url withReturnType:(GLBarcodeDatabaseReturnType)returnType andSearchBlock:(NSRange (^)(NSString*string, NSString *barcode))searchBlock;

- (void)addBarcodeDatabaseWithURL:(NSString *)url withReturnType:(GLBarcodeDatabaseReturnType)returnType searchBlock:(NSRange (^)(NSString *, NSString *))searchBlock andBarcodeModifier:(NSString *(^)(NSString *))barcodeBlock;

- (void)fetchNameOfItemWithBarcode:(NSString *)barcode;

@end
