//
//  GLPullToCloseTransitionManager.m
//  GroceryList
//
//  Created by Hakon Hanesand on 3/29/15.

#import <pop/POP.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

#import "GLPullToCloseTransitionManager.h"

#import "POPSpringAnimation+GLAdditions.h"
#import "POPAnimation+GLAnimation.h"

@implementation GLPullToCloseTransitionManager

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 1.0;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    if (self.presenting) {
        [self animatePresentationWithTransitionContext:transitionContext];
    } else {
        [self animateDismissalWithTransitionContext:transitionContext];
    }
}


- (void)animatePresentationWithTransitionContext:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *presentedControllerView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *containerView = [transitionContext containerView];
    
    //position the presented view below the screen
    presentedControllerView.center = translatePoint(containerView.center, 0, CGRectGetHeight(presentedControllerView.frame));
    
    [containerView addSubview:presentedControllerView];
    
    //animate the presented view up to cover the screen
    POPSpringAnimation *animation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionY];
    animation.toValue = @(containerView.center.y);
    animation.springSpeed = 20;
    animation.springBounciness = 0;
    
    [[animation completionSignal] subscribeCompleted:^{
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
    
    [presentedControllerView pop_addAnimation:animation forKey:@"presentPOPModal"];
}

- (void)animateDismissalWithTransitionContext:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *presentedControllerView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *containerView = [transitionContext containerView];
    
    //animate the view offscreen by moving it downwards
    POPSpringAnimation *animation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionY];
    animation.toValue = @(translatePoint(containerView.center, 0, CGRectGetHeight(containerView.frame)).y);
    animation.springSpeed = 20;
    animation.springBounciness = 0;
    
    [[animation completionSignal] subscribeCompleted:^{
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
    
    [presentedControllerView pop_addAnimation:animation forKey:@"dismissPOPModal"];
}

static inline CGPoint translatePoint(CGPoint point, CGFloat dx, CGFloat dy) {
    return CGPointMake(point.x + dx, point.y + dy);
}

@end