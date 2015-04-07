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
    UIViewController *viewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *presentedControllerView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *containerView = [transitionContext containerView];
    
    //position the presented view below the screen
    presentedControllerView.frame = translateRect([transitionContext finalFrameForViewController:viewController], 0, CGRectGetHeight(containerView.bounds));
    
    //animate the presented view up to cover the screen
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        presentedControllerView.center = translatePoint(presentedControllerView.center, 0, -CGRectGetHeight(containerView.bounds));
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:finished];
    }];
}

- (void)animateDismissalWithTransitionContext:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *presentedControllerView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *containerView = [transitionContext containerView];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        presentedControllerView.center = translatePoint(presentedControllerView.center, 0, CGRectGetHeight(containerView.bounds));
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:finished];
    }];
}

static inline CGRect translateRect(CGRect rect, CGFloat dx, CGFloat dy) {
    return CGRectMake(rect.origin.x + dx, rect.origin.y + dy, CGRectGetWidth(rect), CGRectGetHeight(rect));
}

static inline CGPoint translatePoint(CGPoint point, CGFloat dx, CGFloat dy) {
    return CGPointMake(point.x + dx, point.y + dy);
}

@end