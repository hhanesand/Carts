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

/**
 *  Manages interactions with Bing's image search engine
 */
@interface GLBingFetcher : NSObject

+ (GLBingFetcher *)sharedFetcher;

/**
 *  Get an image url for a barcode object by searching bing
 *
 *  @param barcodeObject The barcode object to search for (the name and brand is used)
 *
 *  @return An RACSignal with the modified barcode object
 */
- (RACSignal *)fetchImageURLFromBingForBarcodeObject:(GLBarcodeObject *)barcodeObject;

@end
