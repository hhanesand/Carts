//
//  GLTransitionContext.m
//  GroceryList
//
//  Created by Hakon Hanesand on 3/12/15.
//
//

#import "GLTransitionContext.h"

@interface GLTransitionContext ()
@property (nonatomic, assign) UIModalPresentationStyle presentationStyle;
@property (nonatomic, weak) UIView *containerView;
@property (nonatomic) NSDictionary *viewControllers;
@end

@implementation GLTransitionContext

- (instancetype)initWithFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController {
    NSAssert ([fromViewController isViewLoaded] && fromViewController.view.superview, @"The fromViewController view must reside in the container view");
    
    if (self = [super init]) {
        self.presentationStyle = UIModalPresentationCustom;
        self.containerView = fromViewController.view.superview;
        self.viewControllers = @{UITransitionContextToViewControllerKey : toViewController,
                                 UITransitionContextFromViewControllerKey : fromViewController};
    }
    
    return self;
}

@end
