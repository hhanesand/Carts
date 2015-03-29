//
//  GLAnimationStack.m
//  GroceryList
//
//  Created by Hakon Hanesand on 3/28/15.
//
//

#import "GLAnimationStack.h"
#import "GLAnimation.h"
#import "POPSpringAnimation+GLAdditions.h"

#import <pop/POP.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

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
    return [self.stack.rac_sequence.signal doNext:^(GLAnimation *animation) {
        NSLog(@"Is main thread %@", [NSThread isMainThread] ? @"YES" : @"NO");
        [animation.targetObject pop_addAnimation:animation.animation forKey:animation.identifier];
    }];
}

- (RACSignal *)popAnimationWithTargetObject:(id)target {
    return nil;
}

- (NSMutableArray *)stack {
    if (!_stack) {
        _stack = [NSMutableArray new];
    }
    
    return _stack;
}

@end
