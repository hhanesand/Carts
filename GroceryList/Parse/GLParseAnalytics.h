//
//  GLParseAnalytics.h
//  GroceryList
//
//  Created by Hakon Hanesand on 2/14/15.
//
//

@import Foundation;

@interface GLParseAnalytics : NSObject

@property (nonatomic, readonly) NSString *missingBarcodeFunctionName;

+ (GLParseAnalytics *)shared;

- (void)testCloudFunction;

- (void)trackMissingBarcode:(NSString *)barcode;

@end