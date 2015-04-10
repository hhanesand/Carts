//
//  GLFactualSessionManager.h
//  GroceryList
//
//  Created by Hakon Hanesand on 4/9/15.

#import "AFHTTPSessionManager.h"
#import "GLRACSessionManager.h"

@class RACSignal;

/**
 *  Manages the Factual Global Products API.
 */
@interface GLFactualSessionManager : GLRACSessionManager

/**
 *  Queries Factual for information about this barcode
 *
 *  @param barcode The barcode to search for
 *
 *  @return A signal that returns a dictionary representing the values of the barcode object
 */
- (RACSignal *)queryFactualForBarcode:(NSString *)barcode;

@end
