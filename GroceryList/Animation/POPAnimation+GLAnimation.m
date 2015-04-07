//
//  POPAnimation+GLAnimation.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/3/15.

#import <ReactiveCocoa/ReactiveCocoa.h>

#import "POPAnimation+GLAnimation.h"

@implementation POPAnimation (GLAnimation)

- (RACSignal *)completionSignal {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        if (self.completionBlock) {
            NSLog(@"WARNING : Overwriting completion block on SpringAnimation %@", self);
        }
        
        self.completionBlock = ^(POPAnimation *animation, BOOL done) {
            if (done) {
                [subscriber sendNext:animation];
                [subscriber sendCompleted];
            }
        };
        
        return nil;
    }];
}

@end
