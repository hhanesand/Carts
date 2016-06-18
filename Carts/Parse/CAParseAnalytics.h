//
//  CAParseAnalytics.h
//  Carts
//
//  Created by Hakon Hanesand on 2/14/15.

@import Foundation;

@class CABarcode;

@interface CAParseAnalytics : NSObject

/**
 *  Saves the barcodes that are missing from both Parse and Factual in Parse
 *
 *  @param barcode The barcode that was missing
 */
+  (void)trackMissingBarcode:(CABarcode *)barcode;

@end
