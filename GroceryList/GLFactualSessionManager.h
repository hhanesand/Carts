//
//  GLFactualSessionManager.h
//  GroceryList
//
//  Created by Hakon Hanesand on 4/9/15.

#import "AFHTTPSessionManager.h"
#import "GLRACSessionManager.h"

@class RACSignal;

@interface GLFactualSessionManager : GLRACSessionManager

- (RACSignal *)queryFactualForBarcode:(NSString *)barcode;

@end
