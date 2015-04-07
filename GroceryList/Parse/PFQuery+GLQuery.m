//
//  PFQuery+GLQuery.m
//  GroceryList
//
//  Created by Hakon Hanesand on 3/10/15.

#import <ReactiveCocoa/ReactiveCocoa.h>

#import "PFQuery+GLQuery.h"

@implementation PFQuery (GLQuery)

- (RACSignal *)findObjectsInbackgroundWithRACSignal {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                [subscriber sendNext:objects];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:error];
            }
        }];
        
        return [RACDisposable disposableWithBlock:^{
            [self cancel];
        }];
    }];
}

- (RACSignal *)getFirstObjectWithRACSignal {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (object && !error) {
                [subscriber sendNext:object];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:error];
            }
        }];
    
        return [RACDisposable disposableWithBlock:^{
            [self cancel];
        }];
    }];
}

@end
