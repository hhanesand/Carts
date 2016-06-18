//
//  CAFactualResponseSerializer.m
//  Carts
//
//  Created by Hakon Hanesand on 2/20/15.

#import "CAFactualResponseSerializer.h"

#import "NSDictionary+CACustomKVOOperators.h"

NSString * const kCAFactualNetworkingErrorDomain = @"CartsErrorDomain";
NSString * const kCAFactualDataKeypath = @"@first.response.data";
NSString * const kCAFactualDataValidation = @"response.included_rows";

@implementation CAFactualResponseSerializer

- (id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error {
    NSDictionary *responseObject = [super responseObjectForResponse:response data:data error:error];
    
    if ([[responseObject valueForKeyPath:kCAFactualDataValidation] intValue] == 0) {
        *error = [NSError errorWithDomain:kCAFactualNetworkingErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
        return nil;
    }
    
    return [responseObject valueForKeyPath:kCAFactualDataKeypath];
}

@end
