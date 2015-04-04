//
//  PFUser+GLUser.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/2/15.
//
//

#import "PFUser+GLUser.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation PFUser (GLUser)

+ (RACSignal *)logInInBackgroundWithUsername:(NSString *)username password:(NSString *)password {
	return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
            if (error) {
                [subscriber sendError:error];
            } else {
                [subscriber sendCompleted];
            }
        }];
        
        return nil;
    }];
}

@end
