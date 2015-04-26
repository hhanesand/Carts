//
//  GLFactualResponseSerializer.m
//  GroceryList
//
//  Created by Hakon Hanesand on 2/20/15.

#import "GLFactualResponseSerializer.h"

#import "NSDictionary+GLCustomKVOOperators.h"

NSString * const kGLFactualNetworkingErrorDomain = @"GroceryListErrorDomain";
NSString * const kGLFactualDataKeypath = @"@first.response.data";
NSString * const kGLFactualDataValidation = @"response.included_rows";

@implementation GLFactualResponseSerializer

- (id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error {
    NSDictionary *responseObject = [super responseObjectForResponse:response data:data error:error];
    
    if ([[responseObject valueForKeyPath:kGLFactualDataValidation] intValue] == 0) {
        *error = [NSError errorWithDomain:kGLFactualNetworkingErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
        return nil;
    }
    
    return [responseObject valueForKeyPath:kGLFactualDataKeypath];
}

@end
