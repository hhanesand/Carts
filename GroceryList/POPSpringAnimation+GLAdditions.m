//
//  POPPropertyAnimation+GLReverse.m
//  GroceryList
//
//  Created by Hakon Hanesand on 3/4/15.
//
//

#import "POPSpringAnimation+GLAdditions.h"
#import "POPSpringAnimation.h"
#import "PopBasicAnimation.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation POPSpringAnimation (GLAdditions)

- (POPSpringAnimation *)reverse {
    POPSpringAnimation *reversed = [POPSpringAnimation animationWithPropertyNamed:self.property.name];
    
    reversed.springBounciness = self.springBounciness;
    reversed.springSpeed = self.springSpeed;

    reversed.toValue = self.fromValue;
    reversed.fromValue = self.toValue;
    
    NSLog(@"INFO - Original Animation [%@]\nReversed Animation [%@]", self, reversed);
    
    return reversed;
}

- (RACSignal *)completionSignal {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        if (self.completionBlock) {
            NSLog(@"WARNING : Overwriting completion block on SpringAnimation %@", self);
        }
        
        self.completionBlock = ^(POPAnimation *animation, BOOL done) {
            if (done) {
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
            }
        };
        
        return nil;
    }];
}


@end
