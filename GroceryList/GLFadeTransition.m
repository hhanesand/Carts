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

- (void)animatePresentationWithTransitionContext:(id<UIViewControllerContextTransitioning>)context {
    UIView *presentedViewControllerView = [context viewForKey:UITransitionContextToViewKey];
    UIView *presentingViewControllerView = [context viewForKey:UITransitionContextFromViewKey];
    
    [context.containerView addSubview:presentedViewControllerView];
    [context.containerView sendSubviewToBack:presentedViewControllerView];
    
    POPSpringAnimation *alpha = [POPSpringAnimation animationWithPropertyNamed:kPOPViewAlpha];
    alpha.fromValue = @(1.0);
    alpha.toValue = @(0.0);
    alpha.springSpeed = 16;
    alpha.springBounciness = 0;
    
    POPSpringAnimation *lift = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    lift.fromValue = [NSValue valueWithCGPoint:CGPointMake(1, 1)];
    lift.toValue = [NSValue valueWithCGPoint:CGPointMake(2, 2)];
    alpha.springSpeed = 16;
    alpha.springBounciness = 0;
    
    //increase scale and reduce opacity on the view doing the presenting (creates a lifting effect)
    [presentingViewControllerView pop_addAnimation:alpha forKey:@"presenting_transition_alpha"];
    [presentingViewControllerView pop_addAnimation:lift forKey:@"presenting_transition_scale"];
    
    lift.completionBlock = ^(POPAnimation *animation, BOOL finished) {
        if (finished) {
            //TODO : rac signal?
            [context completeTransition:YES];
        }
    };
}

- (void)animateDismissalWithTransitionContext:(id<UIViewControllerContextTransitioning>)context {
    UIView *presentingViewControllerView = [context viewForKey:UITransitionContextFromViewKey];
    
    POPSpringAnimation *alpha = [POPSpringAnimation animationWithPropertyNamed:kPOPViewAlpha];
    alpha.fromValue = @(0.0);
    alpha.toValue = @(1.0);
    alpha.springSpeed = 16;
    alpha.springBounciness = 0;
    
    POPSpringAnimation *lift = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    lift.fromValue = [NSValue valueWithCGPoint:CGPointMake(2, 2)];
    lift.toValue = [NSValue valueWithCGPoint:CGPointMake(1, 1)];
    alpha.springSpeed = 16;
    alpha.springBounciness = 0;
    
    //de-scale and increase opacity on the presenting view to "lower" it back down
    [presentingViewControllerView pop_addAnimation:alpha forKey:@"dismissal_transition_alpha"];
    [presentingViewControllerView pop_addAnimation:lift forKey:@"dismissal_transition_scale"];
    
    lift.completionBlock = ^(POPAnimation *animation, BOOL finished) {
        if (finished) {
            //TODO :rac signal?
            [context completeTransition:YES];
        }
    };
}

@end
