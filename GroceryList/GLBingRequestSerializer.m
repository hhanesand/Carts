//
//  GLBingRequestSerializer.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/8/15.
//
//

#import "GLBingRequestSerializer.h"

NSString * const method = @"GET";

@interface GLBingRequestSerializer ()
@property (nonatomic) NSString *bingApiKey;
@property (nonatomic) NSString *authorizationData;
@end

@implementation GLBingRequestSerializer

+ (instancetype)serializer {
    GLBingRequestSerializer *serializer = [[GLBingRequestSerializer alloc] init];
    serializer.baseURL = @"https://api.datamarket.azure.com/Bing/Search/v1/Image";
    serializer.parameters = @{@"format" : @"JSON",
                              @"top" : @"1",
                              @"adult" : @"strict"};
    serializer.thumbnailKeyPath = @"d.results.Thumbnail.MediaUrl";
    
    return serializer;
}

- (NSMutableURLRequest *)bingRequestWithQueryString:(NSString *)query error:(NSError *__autoreleasing *)error {
    NSMutableDictionary *parameters = [self.parameters mutableCopy];
    [parameters setObject:query forKey:@"query"];
    
    NSMutableURLRequest *request = [super requestWithMethod:method URLString:self.baseURL parameters:parameters error:error];
    [request setValue:self.authorizationData forHTTPHeaderField:@"Authorization"];
    
    return request;
}

- (NSString *)bingApiKey {
    if (!_bingApiKey) {
        _bingApiKey = @"4RmJ+kjMTCXg36g0LmPrDTiLgF3Xb3EqJjBGwzqXC9A";
    }
    
    return _bingApiKey;
}

- (NSString *)authorizationData {
    if (!_authorizationData) {
        NSData *authData = [[NSString stringWithFormat:@"%@:%@", self.bingApiKey, self.bingApiKey] dataUsingEncoding:NSUTF8StringEncoding];
        _authorizationData =  [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]];
    }
    
    return _authorizationData;
}


@end
