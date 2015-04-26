//
//  GLTwitterRequestSerializer.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/25/15.

#import "GLTwitterRequestSerializer.h"
#import <Parse/Parse.h>

@implementation GLTwitterRequestSerializer

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method URLString:(NSString *)URLString parameters:(id)parameters error:(NSError *__autoreleasing *)error {
    NSMutableURLRequest *request = [super requestWithMethod:method URLString:URLString parameters:parameters error:error];
    [[PFTwitterUtils twitter] signRequest:request];
    return request;
}

@end