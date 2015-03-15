//
//  GLTransition.m
//  GroceryList
//
//  Created by Hakon Hanesand on 3/13/15.
//
//

#import <ReactiveCocoa/ReactiveCocoa.h>
#import "GLTransition.h"
#import "MustOverride.h"

@implementation GLTransition

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    //using pop spring animations, which do not have a time value...
    //TODO : figure out effect of exceeding animation time
    return 0;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)context {
    if (self.isPresenting) {
        [self animatePresentationWithTransitionContext:context];
    } else {
        [self animateDismissalWithTransitionContext:context];
    }
}

- (void)animatePresentationWithTransitionContext:(id<UIViewControllerContextTransitioning>)context {
    [[context containerView] addSubview:[context viewForKey:UITransitionContextToViewKey]];
    [context completeTransition:YES];
}

- (void)animateDismissalWithTransitionContext:(id<UIViewControllerContextTransitioning>)context {
    [context completeTransition:YES];
}

@end
