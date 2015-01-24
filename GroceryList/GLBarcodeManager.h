//
//  GLBarcodeManager.h
//  GroceryList
//
//  Created by Hakon Hanesand on 1/23/15.
//
//

#import <Foundation/Foundation.h>
#import "GLBarcodeDatabase.h"

@interface GLBarcodeManager : NSObject

+ (GLBarcodeManager *)sharedManager;

- (void)addBarcodeDatabaseWithURL:(NSString *)url withReturnType:(enum GLBarcodeDatabaseReturnType)returnType andSearchBlock:(NSRange (^)(NSString*string, NSString *barcode))searchBlock;

- (NSMutableArray *)fetchNameOfItemWithBarcode:(NSString *)barcode;

@end
