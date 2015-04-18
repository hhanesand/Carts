//
//  PFObject+GLPFObject.m
//  GroceryList
//
//  Created by Hakon Hanesand on 3/11/15.

#import <ReactiveCocoa/ReactiveCocoa.h>

#import "PFObject+GLPFObject.h"

@implementation PFObject (GLPFObject)

+ (RACSignal *)pinAllWithSignal:(NSArray *)objects {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [PFObject pinAllInBackground:objects block:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:error];
            }
        }];
        
        return nil;
    }];
}

+ (RACSignal *)unpinAllWithSignal {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [PFObject unpinAllObjectsInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [subscriber sendCompleted];
        }];
        
        return nil;
    }];
}

- (RACSignal *)pinWithSignal {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self pinInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:error];
            }
        }];
        
        return nil;
    }];
}

- (RACSignal *)saveWithSignal {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:error];
            }
        }];
        
        return nil;
    }];
}



@end
