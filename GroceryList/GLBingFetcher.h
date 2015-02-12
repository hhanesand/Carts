//
//  GLBingFetcher.h
//  GroceryList
//
//  Created by Hakon Hanesand on 2/7/15.
//
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "GLBarcodeItem.h"

@class RACSignal;

@interface GLBingFetcher : NSObject

+ (GLBingFetcher *)sharedFetcher;

- (RACSignal *)fetchImageURLFromBingForBarcodeItem:(GLBarcodeItem *)barcodeItem;

@end
