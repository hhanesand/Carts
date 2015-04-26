//
//  GLTwitterSessionManager.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/25/15.

#import "GLTwitterSessionManager.h"
#import "GLTwitterRequestSerializer.h"

NSString * const kGLTwitterURL = @"https://api.twitter.com/1.1/";

@implementation GLTwitterSessionManager

+ (instancetype)manager {
    return [[GLTwitterSessionManager alloc] init];
}

- (instancetype)init {
    if (self = [super initWithBaseURL:[NSURL URLWithString:kGLTwitterURL]]) {
        self.requestSerializer = [GLTwitterRequestSerializer serializer];
        self.responseSerializer = [AFJSONResponseSerializer serializer];
    }
    
    return self;
}

- (instancetype)initWithBaseURL:(NSURL *)url {
    NSAssert(NO, @"Use either +manager or -init to instantiate a GLTwitterSessionManager");
    return nil;
}

- (RACSignal *)requestTwitterUserWithID:(NSString *)userID {
    return [self GET:@"users/show.json" parameters:@{@"user_id" : userID}];
}

@end

