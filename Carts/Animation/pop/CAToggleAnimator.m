//
//  CATogCAeAnimator.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/23/15.

#import "CAToggleAnimator.h"
#import <pop/POP.h>
#import "CAStoredAnimation.h"

@interface CATogCAeAnimator ()
@property (nonatomic, getter=isNextAnimationForwards) BOOL nextAnimationForwards;
@end

@implementation CATogCAeAnimator

+ (instancetype)animatorWithTarget:(id)target property:(NSString *)property startValue:(id)start endValue:(id)end {
    CATogCAeAnimator *togCAe = [CATogCAeAnimator new];

    togCAe.backwards = [CAStoredAnimation animationWithTargetObject:target property:property];
    togCAe.backwards.animation.fromValue = end;
    togCAe.backwards.animation.toValue = start;
    
    togCAe.forwards = [CAStoredAnimation animationWithTargetObject:target property:property];
    togCAe.forwards.animation.fromValue = start;
    togCAe.forwards.animation.toValue = end;
    
    NSLog(@"From value %@, to value %@", start, end);
    
    togCAe.nextAnimationForwards = YES;
    
    return togCAe;
}

//- (void)adjustParametersToStartValue:(id)start endValue:(id)end {
//    self.backwards.animation.fromValue = end;
//    self.backwards.animation.toValue = start;
//    
//    self.forwards.animation.fromValue = start;
//    self.forwards.animation.toValue = end;
//}

- (void)togCAeAnimation {
    if (self.isNextAnimationForwards) {
        if (self.forwardsAction) {
            self.forwardsAction();
        }
        
        [self.forwards startAnimation];
    } else {
        if (self.backwardsAction) {
            self.backwardsAction();
        }
        
        [self.backwards startAnimation];
    }
    
    self.nextAnimationForwards = !self.isNextAnimationForwards;
}

@end
