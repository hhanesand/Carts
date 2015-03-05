//
//  GLAnimationStack.m
//  GroceryList
//
//  Created by Hakon Hanesand on 3/4/15.
//
//

#import "GLAnimationStack.h"
#import "GLAnimationStore.h"
#import <pop/POP.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "POPPropertyAnimation+GLAdditions.h"

@interface GLAnimationStack()
@property (nonatomic) NSMutableArray *animationStack;
@end

@implementation GLAnimationStack

- (void)pushAnimation:(POPPropertyAnimation *)anim withTargetObject:(id)targetObject forKey:(NSString *)key {
    GLAnimationStore *animation = [GLAnimationStore objectWithAnimation:[POPPropertyAnimation reverseAnimation:anim] onTargetObject:targetObject];
    [self.animationStack addObject:animation];
    [targetObject pop_addAnimation:anim forKey:key];
}

- (RACSignal *)popAnimation {
    RACSubject *animationCompletionSignal = [RACSubject subject];
    
    GLAnimationStore *reverseAnimation = [self.animationStack lastObject];
    [self.animationStack removeLastObject];
    
    reverseAnimation.animation.completionBlock = ^(POPAnimation *animation, BOOL finished) {
        if (finished) {
            [animationCompletionSignal sendNext:[RACTupleNil tupleNil]];
            [animationCompletionSignal sendCompleted];
        }
    };
    
    [reverseAnimation.targetObject pop_addAnimation:reverseAnimation.animation forKey:@"reverseAnimation"];
    return animationCompletionSignal;
}

- (RACSignal *)popAllAnimations {
    NSMutableArray *signals = [NSMutableArray new];
    
    while ([self.animationStack count] != 0) {
        [signals addObject:[self popAnimation]];
    }
    
    return [[RACSignal combineLatest:signals] map:^id(id x) {
        return @(YES);
    }];
}

- (NSMutableArray *)animationStack {
    if (!_animationStack) {
        _animationStack = [NSMutableArray new];
    }
    
    return _animationStack;
}

@end