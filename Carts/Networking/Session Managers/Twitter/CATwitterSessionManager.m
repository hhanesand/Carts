//
//  CATwitterSessionManager.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/25/15.

#import "CATwitterSessionManager.h"
#import "CATwitterRequestSerializer.h"

NSString * const kCATwitterURL = @"https://api.twitter.com/1.1/";

@implementation CATwitterSessionManager

+ (instancetype)manager {
    return [[CATwitterSessionManager alloc] init];
}

- (instancetype)init {
    if (self = [super initWithBaseURL:[NSURL URLWithString:kCATwitterURL]]) {
        self.requestSerializer = [CATwitterRequestSerializer serializer];
        self.responseSerializer = [AFJSONResponseSerializer serializer];
    }
    
    return self;
}

- (instancetype)initWithBaseURL:(NSURL *)url {
    NSAssert(NO, @"Use either +manager or -init to instantiate a CATwitterSessionManager");
    return nil;
}

- (RACSignal *)requestTwitterUserWithID:(NSString *)userID {
    return [self GET:@"users/show.json" parameters:@{@"user_id" : userID}];
}

@end

