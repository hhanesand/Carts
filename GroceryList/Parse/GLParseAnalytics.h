//
//  GLParseAnalytics.h
//  GroceryList
//
//  Created by Hakon Hanesand on 2/14/15.

@import Foundation;

@class GLBarcode;

@interface GLParseAnalytics : NSObject

/**
 *  Saves the barcodes that are missing from both Parse and Factual in Parse
 *
 *  @param barcode The barcode that was missing
 */
+  (void)trackMissingBarcode:(GLBarcode *)barcode;

@end