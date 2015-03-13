//
//  GLFadeTransition.m
//  GroceryList
//
//  Created by Hakon Hanesand on 3/12/15.
//
//

#import "GLFadeTransition.h"
#import <pop/POP.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "POPPropertyAnimation+GLAdditions.h"

@implementation GLFadeTransition

- (void)animateTransitionWithContext:(GLTransitioningContext *)context {
    UIViewController *fromViewController = context.fromViewController;
    UIViewController *toViewController = context.toViewController;
    
    if (self.reverse) {
        [context.containerView addSubview:toViewController.view];
    } else {
        [context.containerView addSubview:toViewController.view];
        [context.containerView sendSubviewToBack:toViewController.view];
    }
    
    POPSpringAnimation *alpha = [POPSpringAnimation animationWithPropertyNamed:kPOPViewAlpha];
    alpha.fromValue = self.reverse ? @(0.0) : @(1.0);
    alpha.toValue = self.reverse ? @(1.0) : @(0.0);
    alpha.springSpeed = 16;
    alpha.springBounciness = 0;
    
    POPSpringAnimation *lift = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    lift.fromValue = [NSValue valueWithCGPoint:(self.reverse ? CGPointMake(2, 2) : CGPointMake(1, 1))];
    lift.toValue = [NSValue valueWithCGPoint:(self.reverse ? CGPointMake(1, 1) : CGPointMake(2, 2))];
    alpha.springSpeed = 16;
    alpha.springBounciness = 0;
    
    if (self.reverse) {
        [toViewController.view pop_addAnimation:alpha forKey:@"transition_alpha"];
        [toViewController.view pop_addAnimation:lift forKey:@"transition_scale"];
    } else {
        [fromViewController.view pop_addAnimation:alpha forKey:@"transition_alpha"];
        [fromViewController.view pop_addAnimation:lift forKey:@"transition_scale"];
    }
    
    lift.completionBlock = ^(POPAnimation *animation, BOOL finished) {
        if (finished) {
            [self.completionSignal sendCompleted];
        }
    };
}

@end
