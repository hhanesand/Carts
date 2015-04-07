//
//  GLParseAnalytics.h
//  GroceryList
//
//  Created by Hakon Hanesand on 2/14/15.

@import Foundation;

/**
 *  Manages analytics for the app
 */
@interface GLParseAnalytics : NSObject

@property (nonatomic, readonly) NSString *missingBarcodeFunctionName;

+ (GLParseAnalytics *)shared;

- (void)testCloudFunction;

/**
 *  Called when the user scans a barcode that is not in Factual or Parse
 *
 *  @param barcode The barcode that was missing
 */
- (void)trackMissingBarcode:(NSString *)barcode;

@end