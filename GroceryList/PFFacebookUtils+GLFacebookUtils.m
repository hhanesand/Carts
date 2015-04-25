//
//  PFFacebookUtils+GLFacebookUtils.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/24/15.

#import "PFFacebookUtils+GLFacebookUtils.h"

@implementation PFFacebookUtils (GLFacebookUtils)

+ (RACSignal *)logInWithSignalWithReadPermissions:(PF_NULLABLE NSArray *)permissions {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self logInInBackgroundWithReadPermissions:permissions block:^(PFUser *user, NSError *error) {
            if (error) {
                NSLog(@"Error in facebook login %@", error);
                [subscriber sendError:error];
            } else {
                [subscriber sendNext:user];
                [subscriber sendCompleted];
            }
        }];
        
        return nil;
    }];
}

@end
