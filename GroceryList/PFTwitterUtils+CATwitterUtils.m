//
//  PFTwitterUtils+GLTwitterUtils.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/25/15.

#import "PFTwitterUtils+GLTwitterUtils.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation PFTwitterUtils (GLTwitterUtils)

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
