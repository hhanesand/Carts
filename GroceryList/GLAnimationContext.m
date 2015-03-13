//
//  GLAnimationContext.m
//  GroceryList
//
//  Created by Hakon Hanesand on 3/12/15.
//
//

#import "GLAnimationContext.h"
#import "MustOverride.h"

@implementation GLAnimationContext

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    if (self = [super init]) {
        [self.stack addObject:rootViewController];
    }
    
    return self;
}

- (NSMutableArray *)stack {
    if (!_stack) {
        _stack = [NSMutableArray new];
    }
    
    return _stack;
}

- (void)animateFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController withTransition:(GLTransition *)transition {
    [transition animateFromViewController:fromViewController toViewController:toViewController];
}

- (UIViewController *)getSecondViewController {
    return self.stack[[self.stack count] - 2];
}

- (UIViewController *)getTopViewController {
    return [self.stack lastObject];
}

@end
