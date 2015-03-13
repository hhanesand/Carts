//
//  GLTransitionManager.m
//  GroceryList
//
//  Created by Hakon Hanesand on 3/13/15.
//
//

#import "GLTransitionManager.h"
#import "GLTransition.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface GLTransitionManager ()
@property (nonatomic, weak) UIWindow *window;
@property (nonatomic, weak) UIViewController *rootController;
@end

@implementation GLTransitionManager

static GLTransitionManager *shared;

+ (GLTransitionManager *)sharedInstance {
    return shared;
}

+ (void)setSharedInstance:(GLTransitionManager *)new {
    shared = new;
}

- (instancetype)initWithRootWindow:(UIWindow *)window {
    if (self = [super init]) {
        self.window = window;
        self.rootController = window.rootViewController;
        self.viewControllerStack = [NSMutableArray new];
        [self.viewControllerStack addObject:self.rootController];
    }
    
    return self;
}

- (void)pushViewController:(UIViewController *)toViewController withAnimation:(GLTransition *)transition {
    NSAssert(![self.viewControllerStack containsObject:toViewController], @"The same view controller can not be pushed onto the stack more than once.");
    
    UIViewController *fromViewController = [self getTopViewController];
    
    [self transitionFromViewController:fromViewController toViewController:toViewController withTransition:transition];
    [self.viewControllerStack addObject:toViewController];
}

- (void)popViewControllerWithAnimation:(GLTransition *)transition {
    UIViewController *fromViewController = [self getTopViewController];
    UIViewController *toViewController = [self getSecondaryViewController];
    
    [self transitionFromViewController:fromViewController toViewController:toViewController withTransition:transition];
    [self.viewControllerStack removeObject:fromViewController];
}

- (void)transitionFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController withTransition:(GLTransition *)transition {
    [self.rootController addChildViewController:toViewController];
    
    [transition.completionSignal subscribeCompleted:^() {
        [fromViewController willMoveToParentViewController:nil];
        [fromViewController.view removeFromSuperview];
        [fromViewController removeFromParentViewController];
        [fromViewController didMoveToParentViewController:nil];
        [toViewController didMoveToParentViewController:self.rootController];
    }];
    
    GLTransitioningContext *context = [[GLTransitioningContext alloc] initWithFromViewController:fromViewController toViewController:toViewController];
    [transition animateTransitionWithContext:context];
}

- (UIViewController *)getTopViewController {
    return [self.viewControllerStack lastObject];
}

- (UIViewController *)getSecondaryViewController {
    return self.viewControllerStack[[self.viewControllerStack count] - 2];
}


@end
