//
//  GLParseAnalytics.h
//  GroceryList
//
//  Created by Hakon Hanesand on 2/14/15.
//
//

#import <Foundation/Foundation.h>

@interface GLParseAnalytics : NSObject

@property (nonatomic, readonly) NSString *missingBarcodeFunctionName;

+ (GLParseAnalytics *)shared;

- (void)trackMissingBarcode:(NSString *)barcode;

- (void)testCloudFunction;

@end