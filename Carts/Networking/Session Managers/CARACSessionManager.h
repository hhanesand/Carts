//
//  CARACSessionManager.h
//  GroceryList
//
//  Created by Hakon Hanesand on 4/9/15.

#import <AFNetworking/AFHTTPSessionManager.h>

@class RACSignal;

/**
 *  Wrapper around AFHTTPSessionManager that returns values on signals instead of blocks
 */
@interface CARACSessionManager : AFHTTPSessionManager

/**
 *  Issues a GET request by using -GET:parameters:success:failure: on AFHTTPSessionManager
 *
 *  @param path       The path to the URL resource, relative to the base url
 *  @param parameters The parameters for the GET request
 *
 *  @return An RACSignal that either returns the response object and then completes, or sends an error
 */
- (RACSignal *)GET:(NSString *)path parameters:(id)parameters;

@end
