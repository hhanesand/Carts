//
//  GLBingFetcher.h
//  GroceryList
//
//  Created by Hakon Hanesand on 2/7/15.

@import Foundation;

@class GLBarcodeObject;
@class RACSignal;
@class GLBingFetcher;
@class GLListObject;

@interface GLBingFetcher : NSObject

+ (GLBingFetcher *)sharedFetcher;

- (RACSignal *)fetchImageURLFromBingForBarcodeObject:(GLBarcodeObject *)barcodeObject;

@end
