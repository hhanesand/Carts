//
//  CAAnimationStack.m
//  GroceryList
//
//  Created by Hakon Hanesand on 3/28/15.

#import <pop/POP.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

#import "CAAnimationStack.h"
#import "CAAnimation.h"

#import "POPSpringAnimation+CAAdditions.h"
#import "POPAnimation+CAAnimation.h"

@implementation CAAnimationStack

- (void)pushAnimation:(POPSpringAnimation *)animation withTargetObject:(id)target andDescription:(NSString *)description {
    [target pop_addAnimation:animation forKey:description];
    CAAnimation *reversedAnimation = [CAAnimation animationWithSpring:[animation reverse] description:description targetObject:target];
    [self.stack addObject:reversedAnimation];
}

- (RACSignal *)popAnimation {
    CAAnimation *topAnimation = [self.stack lastObject];
    [self.stack removeLastObject];
    [topAnimation startAnimation];
    return [topAnimation.animation completionSignal];
}

- (RACSignal *)popAllAnimations {
    return [[[self.stack.rac_sequence.signal doNext:^(CAAnimation *animation) {
        [animation startAnimation];
    }] flattenMap:^RACStream *(CAAnimation *animation) {
        return [animation.animation completionSignal];
    }] doCompleted:^{
        [self.stack removeAllObjects];
    }];
}

- (RACSignal *)popAnimationWithTargetObject:(id)target {
    return [[[self.stack.rac_sequence.signal filter:^BOOL(CAAnimation *animation) {
        return [animation.targetObject isEqual:target];
    }] doNext:^(CAAnimation *animation) {
        [animation startAnimation];
        [self.stack removeObject:animation];
    }] flattenMap:^RACStream *(CAAnimation *animation) {
        return [animation.animation completionSignal];
    }];
}

- (NSMutableArray *)stack {
    if (!_stack) {
        _stack = [NSMutableArray new];
    }
    
    return _stack;
}

@end
