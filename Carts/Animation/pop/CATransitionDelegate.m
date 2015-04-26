//
//  CATransitionDelegate.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/13/15.

#import "CATransitionDelegate.h"
#import "CAReversibleTransition.h"

@interface CATransitionDelegate ()
@property (nonatomic, weak) id controller;
@property (nonatomic) Class presentationControllerClass;
@property (nonatomic) Class animatorClass;
@property (nonatomic) id<UIViewControllerAnimatedTransitioning, CAReversibleTransition> animator;
@end

@implementation CATransitionDelegate

- (instancetype)initWithController:(id)controller presentationController:(Class)presentationControllerClass transitionManager:(Class)transitionManagerClass {
    if (self = [super init]) {
        NSParameterAssert([presentationControllerClass isSubclassOfClass:[UIPresentationController class]]);
        NSParameterAssert([transitionManagerClass conformsToProtocol:@protocol(UIViewControllerAnimatedTransitioning)] && [transitionManagerClass conformsToProtocol:@protocol(CAReversibleTransition)]);
        
        self.controller = controller;
        self.presentationControllerClass = presentationControllerClass;
        self.animatorClass = transitionManagerClass;
    }
    
    return self;
}

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)to presentingViewController:(UIViewController *)from sourceViewController:(UIViewController *)source {
    if ([to isEqual:self]) {
        return [[self.presentationControllerClass alloc] initWithPresentedViewController:to presentingViewController:from];
    }
    
    return nil;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)to presentingController:(UIViewController *)from sourceController:(UIViewController *)source {
    if ([to isEqual:self]) {
        self.animator.presenting = YES;
        return self.animator;
    }
    
    return nil;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    if ([dismissed isEqual:self]) {
        self.animator.presenting = NO;
        return self.animator;
    }
    
    return nil;
}

- (id<UIViewControllerAnimatedTransitioning,CAReversibleTransition>)animator {
    if (!_animator) {
        _animator = [[self.animatorClass alloc] init];
    }
    
    return _animator;
}

@end
