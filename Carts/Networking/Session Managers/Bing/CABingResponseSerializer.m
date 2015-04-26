//
//  CABingResponseSerializer.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/9/15.
//
//

#import "CABingResponseSerializer.h"

NSString * const kCABingNetworkingErrorDomain = @"GroceryListErrorDomain";
NSString * const kCABingDataKeypath = @"d.results.Thumbnail.MediaUrl";
NSString * const kCABingValidationKeypath = @"d.results.Thumbnail.MediaUrl";

@implementation CABingResponseSerializer

- (id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error {
    NSDictionary *responseObject = [super responseObjectForResponse:response data:data error:error];
    
    if (![responseObject valueForKeyPath:kCABingValidationKeypath]) {
        *error = [NSError errorWithDomain:kCABingNetworkingErrorDomain code:NSURLErrorFileDoesNotExist userInfo:@{NSLocalizedDescriptionKey : [responseObject description]}];
        return nil;
    }
    
    return [responseObject valueForKeyPath:kCABingDataKeypath];
}

@end
