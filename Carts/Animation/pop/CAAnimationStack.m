//
//  GLAnimationStack.m
//  GroceryList
//
//  Created by Hakon Hanesand on 3/28/15.

#import <pop/POP.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

#import "GLAnimationStack.h"
#import "GLAnimation.h"

#import "POPSpringAnimation+GLAdditions.h"
#import "POPAnimation+GLAnimation.h"

@implementation GLAnimationStack

- (void)pushAnimation:(POPSpringAnimation *)animation withTargetObject:(id)target andDescription:(NSString *)description {
    [target pop_addAnimation:animation forKey:description];
    GLAnimation *reversedAnimation = [GLAnimation animationWithSpring:[animation reverse] description:description targetObject:target];
    [self.stack addObject:reversedAnimation];
}

- (RACSignal *)popAnimation {
    GLAnimation *topAnimation = [self.stack lastObject];
    [self.stack removeLastObject];
    [topAnimation startAnimation];
    return [topAnimation.animation completionSignal];
}

- (RACSignal *)popAllAnimations {
    return [[[self.stack.rac_sequence.signal doNext:^(GLAnimation *animation) {
        [animation startAnimation];
    }] flattenMap:^RACStream *(GLAnimation *animation) {
        return [animation.animation completionSignal];
    }] doCompleted:^{
        [self.stack removeAllObjects];
    }];
}

- (RACSignal *)popAnimationWithTargetObject:(id)target {
    return [[[self.stack.rac_sequence.signal filter:^BOOL(GLAnimation *animation) {
        return [animation.targetObject isEqual:target];
    }] doNext:^(GLAnimation *animation) {
        [animation startAnimation];
        [self.stack removeObject:animation];
    }] flattenMap:^RACStream *(GLAnimation *animation) {
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
