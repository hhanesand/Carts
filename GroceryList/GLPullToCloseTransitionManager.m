//
//  GLPullToCloseTransitionManager.m
//  GroceryList
//
//  Created by Hakon Hanesand on 3/29/15.
//
//

#import "GLPullToCloseTransitionManager.h"
#import <pop/POP.h>
#import "POPSpringAnimation+GLAdditions.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "POPAnimation+GLAnimation.h"

@implementation GLPullToCloseTransitionManager

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 1.0;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *to = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *from = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UIView *container = [transitionContext containerView];
    [container insertSubview:to.view belowSubview:from.view];
    
    CGFloat offset = CGRectGetMidY([UIScreen mainScreen].applicationFrame);
    
    POPSpringAnimation *slide = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionY];
    slide.fromValue = self.presenting ? @(offset + CGRectGetMidY(to.view.frame)) : @(CGRectGetMidY(to.view.frame));
    slide.toValue = self.presenting ? @(CGRectGetMidY(to.view.frame)) : @(offset + CGRectGetMidY(to.view.frame));
    slide.springSpeed = 15;
    slide.springBounciness = 0;
    
    [[slide completionSignal] subscribeCompleted:^{
        [transitionContext completeTransition:YES];
    }];
    
    [to.view pop_addAnimation:slide forKey:@"modalPopover"];
}

@end