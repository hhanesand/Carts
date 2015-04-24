//
//  GLToggleAnimator.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/23/15.

#import "GLToggleAnimator.h"
#import <pop/POP.h>
#import "GLAnimation.h"

@interface GLToggleAnimator ()
@property (nonatomic, getter=isNextAnimationForwards) BOOL nextAnimationForwards;

@property (nonatomic, copy) void (^forwardsAction)();
@property (nonatomic, copy) void (^backwardsAction)();
@end

@implementation GLToggleAnimator

+ (instancetype)animatorWithTarget:(id)target property:(NSString *)property startValue:(id)start endValue:(id)end {
    GLToggleAnimator *toggle = [GLToggleAnimator new];

    toggle.backwards = [GLAnimation animationWithTargetObject:target property:property];
    toggle.backwards.animation.fromValue = end;
    toggle.backwards.animation.toValue = start;
    
    toggle.forwards = [GLAnimation animationWithTargetObject:target property:property];
    toggle.forwards.animation.fromValue = start;
    toggle.forwards.animation.toValue = end;
    
    NSLog(@"From value %@, to value %@", start, end);
    
    toggle.nextAnimationForwards = YES;
    
    return toggle;
}

//- (void)adjustParametersToStartValue:(id)start endValue:(id)end {
//    self.backwards.animation.fromValue = end;
//    self.backwards.animation.toValue = start;
//    
//    self.forwards.animation.fromValue = start;
//    self.forwards.animation.toValue = end;
//}

- (void)performAlongsideForwardAnimation:(void (^)())action {
    self.forwardsAction = action;
}

- (void)performAlongsideBackwardAnimation:(void (^)())action {
    self.backwardsAction = action;
}

- (void)toggleAnimation {
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
