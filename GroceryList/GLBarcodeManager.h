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

+ (GLBarcodeManager *)sharedManager;

- (void)addBarcodeDatabaseWithURL:(NSString *)url withReturnType:(enum GLBarcodeDatabaseReturnType)returnType andSearchBlock:(NSRange (^)(NSString*string, NSString *barcode))searchBlock;

- (void)addBarcodeDatabaseWithURL:(NSString *)url withReturnType:(enum GLBarcodeDatabaseReturnType)returnType searchBlock:(NSRange (^)(NSString *, NSString *))searchBlock andBarcodeModifier:(NSString *(^)(NSString *))barcodeBlock;

- (void)fetchNameOfItemWithBarcode:(NSString *)barcode;

@end
