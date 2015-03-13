//
//  GLBarcodeManager.h
//  GroceryList
//
//  Created by Hakon Hanesand on 1/23/15.
//
//

#import <Foundation/Foundation.h>

@class RACSignal;

@interface GLBarcodeManager : NSObject

- (RACSignal *)queryFactualForBarcode:(NSString *)barcode;

@end
