//
//  PFQuery+GLQuery.m
//  GroceryList
//
//  Created by Hakon Hanesand on 3/10/15.
//
//

#import "PFQuery+GLQuery.h"
#import "ReactiveCocoa.h"

@implementation PFQuery (GLQuery)

- (RACSignal *)findObjectsInbackgroundWithRACSignal {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSError *error;
        NSArray *objects = [self findObjects:&error];
        
        [subscriber sendNext:objects];
        [subscriber sendCompleted];
        
        return [RACDisposable disposableWithBlock:^{
            [self cancel];
        }];
    }];
}

- (RACSignal *)getFirstObjectWithRACSignal {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSError *error;
        PFObject *object = [self getFirstObject:&error];
        
        if (object && !error) {
            [subscriber sendNext:object];
            [subscriber sendCompleted];
        } else {
            [subscriber sendError:error];
        }
        
        return [RACDisposable disposableWithBlock:^{
            [self cancel];
        }];
    }];
}

@end
