//
//  GLBarcodeManager.h
//  GroceryList
//
//  Created by Hakon Hanesand on 1/23/15.
//
//

#import <Foundation/Foundation.h>
#import "GLBarcodeDatabase.h"
#import "AFNetworking.h"
#import "AFHTTPRequestOperationManager+RACSupport.h"

@interface GLBarcodeManager : NSObject

@property (nonatomic) RACSubject *barcodeItemSignal;
@property (nonatomic) NSString *notification;

- (void)addBarcodeDatabase:(GLBarcodeDatabase *)database;

- (RACSignal *)fetchNameOfItemWithBarcode:(NSString *)barcode;

@end
