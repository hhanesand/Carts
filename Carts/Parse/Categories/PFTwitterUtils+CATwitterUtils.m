//
//  PFTwitterUtils+CATwitterUtils.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/25/15.

#import "PFTwitterUtils+CATwitterUtils.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation PFTwitterUtils (CATwitterUtils)

+ (RACSignal *)logInWithSignal {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [PFTwitterUtils logInWithBlock:^(PFUser *user, NSError *error) {
            if (error) {
                NSLog(@"Error in twitter logon");
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
