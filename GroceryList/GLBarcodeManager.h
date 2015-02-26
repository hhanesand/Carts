//
//  GLBarcodeManager.h
//  GroceryList
//
//  Created by Hakon Hanesand on 1/23/15.
//
//

#import <Foundation/Foundation.h>

@class RACSignal;
@class GLBarcodeItem;

@interface GLBarcodeManager : NSObject

- (RACSignal *)queryFactualForItem:(GLBarcodeItem *)barcodeItem;

@end
