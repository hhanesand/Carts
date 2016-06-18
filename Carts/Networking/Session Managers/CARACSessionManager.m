//
//  CARACSessionManager.m
//  Carts
//
//  Created by Hakon Hanesand on 4/9/15.

#import <ReactiveCocoa/ReactiveCocoa.h>

#import "CARACSessionManager.h"

@implementation CARACSessionManager

- (RACSignal *)GET:(NSString *)path parameters:(id)parameters {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [super GET:path parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            [subscriber sendNext:responseObject];
            [subscriber sendCompleted];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [subscriber sendError:error];
        }];
        
        return nil;
    }];
}

@end
