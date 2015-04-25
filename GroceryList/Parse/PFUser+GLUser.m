//
//  PFUser+GLUser.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/2/15.

#import <ReactiveCocoa/ReactiveCocoa.h>

#import "PFUser+GLUser.h"

@implementation PFUser (GLUser)

+ (RACSignal *)logInInBackgroundWithUsername:(NSString *)username password:(NSString *)password {
	return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
            if (error) {
                NSLog(@"Error in logInInBackgroundWithUserName %@", error);
                [subscriber sendError:error];
            } else {
                [subscriber sendCompleted];
            }
        }];
        
        return nil;
    }];
}

- (RACSignal *)signUpInBackgroundWithSignal {
	return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                NSLog(@"Error in signUpInBackgroundWithSignal %@", error);
                [subscriber sendError:error];
            } else {
                [PFUser logInWithUsernameInBackground:self.username password:self.password block:^(PFUser *user, NSError *error) {
                    if (error) {
                        NSLog(@"error in login inside sign up %@", error);
                        [subscriber sendError:error];
                    }
                    
                    [subscriber sendNext:self];
                    [subscriber sendCompleted];
                }];
            }
        }];
        
        return nil;
    }];
}

+ (BOOL)isLoggedIn {
    return [self currentUser] == self;
}

- (NSString *)bestName {
    if([PFUser currentUser] == self) {
        return @"Your Cart";
    } else {
        return [self.username stringByAppendingString:@"'s Cart"];
    }

}

- (GLListObject *)list {
    return [self objectForKey:@"list"];
}

@end
