//
//  GLFactualRequestSerializer.m
//  GroceryList
//
//  Created by Hakon Hanesand on 2/19/15.
//
//

#import <AFOAuth1/KDURLRequestSerialization+OAuth.h>
#import <AFOAuth1/NSMutableURLRequest+OAuth.h>
#import "GLFactualRequestSerializer.h"

@implementation GLFactualRequestSerializer

+ (instancetype)serializer {
    GLFactualRequestSerializer *serializer = [[GLFactualRequestSerializer alloc] init];
    serializer.useOAuth = YES;
    return serializer;
}

- (void)setOAuthorizationHeader:(NSMutableURLRequest *)request
{
    if ([self isUseOAuth]) {
        [request signRequestWithClientIdentifier:@"n5md5zTCv67RV2ctEQKrhK2cAzggCqs3khynDhKT" secret:@"Utn7HYXJ77lW3fTYMFiB9Zvu0GjT1AInnjeqYFct" tokenIdentifier:nil secret:nil usingMethod:OAuthHMAC_SHA1SignatureMethod];
    }else {
        [self clearAuthorizationHeader];
    }
}

@end