//
//  GLBingResponseSerializer.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/9/15.
//
//

#import "GLBingResponseSerializer.h"

NSString * const kGLBingNetworkingErrorDomain = @"GroceryListErrorDomain";
NSString * const kGLBingDataKeypath = @"d.results.Thumbnail.MediaUrl";
NSString * const kGLBingValidationKeypath = @"d.results.Thumbnail.MediaUrl";

@implementation GLBingResponseSerializer

- (id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error {
    NSDictionary *responseObject = [super responseObjectForResponse:response data:data error:error];
    
    if (![responseObject valueForKeyPath:kGLBingValidationKeypath]) {
        *error = [NSError errorWithDomain:kGLBingNetworkingErrorDomain code:NSURLErrorFileDoesNotExist userInfo:@{NSLocalizedDescriptionKey : [responseObject description]}];
        return nil;
    }
    
    return [responseObject valueForKeyPath:kGLBingDataKeypath];
}

@end
