//
//  GLBarcodeManager.h
//  GroceryList
//
//  Created by Hakon Hanesand on 1/23/15.

@import Foundation;

@class RACSignal;

/**
 *  Manages interactions with Factual's barcode database through OAuth1 (http://factual.com)
 */
@interface GLFactualManager : NSObject

/**
 *  Get information about a barcode from factual, returns an error if the barcode does not exist
 *
 *  @param barcode The barcode to search for
 *
 *  @return A signal that will return an array of values describing the object or an error if the item was not found
 */
- (RACSignal *)queryFactualForBarcode:(NSString *)barcode;

@end
