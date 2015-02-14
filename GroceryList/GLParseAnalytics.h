//
//  GLParseAnalytics.h
//  GroceryList
//
//  Created by Hakon Hanesand on 2/14/15.
//
//

#import <Foundation/Foundation.h>

@interface GLParseAnalytics : NSObject

+ (GLParseAnalytics *)shared;

- (void)trackMissingBarcode:(NSString *)barcode;

@end