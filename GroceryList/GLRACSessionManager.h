//
//  GLRACSessionManager.h
//  GroceryList
//
//  Created by Hakon Hanesand on 4/9/15.
//
//

#import "AFHTTPSessionManager.h"

@class RACSignal;

@interface GLRACSessionManager : AFHTTPSessionManager

- (RACSignal *)GET:(NSString *)path parameters:(id)parameters;

@end
