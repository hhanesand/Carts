//
//  PFObject+GLPFObject.m
//  GroceryList
//
//  Created by Hakon Hanesand on 3/11/15.
//
//

#import "PFObject+GLPFObject.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation PFObject (GLPFObject)

+ (RACSignal *)pinAll:(NSArray *)objects withSignalAndName:(NSString *)tagName {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [PFObject pinAllInBackground:objects withName:tagName block:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:error];
            }
        }];
        
        return nil;
    }];
}

+ (RACSignal *)unpinAllWithSignalAndName:(NSString *)tagName {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [PFObject unpinAllObjectsInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
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

- (RACSignal *)pinWithSignalAndName:(NSString *)name {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self pinInBackgroundWithName:name block:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:error];
            }
        }];
        
        return nil;
    }];
}

@end
