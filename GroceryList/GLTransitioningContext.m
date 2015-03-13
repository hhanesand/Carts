//
//  GLContextTransitioning.m
//  GroceryList
//
//  Created by Hakon Hanesand on 3/13/15.
//
//

#import "GLTransitioningContext.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation GLTransitioningContext

- (instancetype)initWithFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController {
    if ((self = [super init])) {
        self.toViewController = toViewController;
        self.fromViewController = fromViewController;
        
        if (!self.fromViewController.view.superview) {
            self.containerView = fromViewController.view;
        } else {
            self.containerView = fromViewController.view.superview;
        }
    }
    
    return self;
}

@end
