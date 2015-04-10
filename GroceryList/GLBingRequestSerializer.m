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
    return [[GLBingRequestSerializer alloc] init];
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method URLString:(NSString *)URLString parameters:(id)parameters error:(NSError *__autoreleasing *)error {
    NSMutableDictionary *combinedRequestSerializerParameters = [self.parameters mutableCopy];
    [combinedRequestSerializerParameters addEntriesFromDictionary:parameters];
    
    NSMutableURLRequest *request = [super requestWithMethod:method URLString:URLString parameters:combinedRequestSerializerParameters error:error];
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

- (NSDictionary *)parameters {
    if (!_parameters) {
        _parameters = @{@"$Format" : @"JSON",
                        @"$top" : @"1",
                        @"Adult" : @"'strict'"};
    }
    
    return _parameters;
}


@end
