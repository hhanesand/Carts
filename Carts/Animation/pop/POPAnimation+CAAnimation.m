//
//  POPAnimation+CAAnimation.m
//  Carts
//
//  Created by Hakon Hanesand on 4/3/15.

#import <ReactiveCocoa/ReactiveCocoa.h>

#import "POPAnimation+CAAnimation.h"

@implementation POPAnimation (CAAnimation)

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
