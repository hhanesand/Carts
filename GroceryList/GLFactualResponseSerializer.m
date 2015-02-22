//
//  GLFactualResponseSerializer.m
//  GroceryList
//
//  Created by Hakon Hanesand on 2/20/15.
//
//

#import "GLFactualResponseSerializer.h"

NSString * const GLNetworkingErrorDomain = @"GroceryListErrorDomain";

@implementation GLFactualResponseSerializer

- (id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error {
    NSDictionary *responseObject = [super responseObjectForResponse:response data:data error:error];
    
    if ([[responseObject valueForKeyPath:@"response.included_rows"] intValue] == 0) {
        *error = [NSError errorWithDomain:GLNetworkingErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
    }
    
    return responseObject;
}

@end
