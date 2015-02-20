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

- (void)addBarcodeDatabase:(GLBarcodeDatabase *)database;

- (RACSignal *)queryFactualForItemWithUPC:(NSString *)barcode;

@end
