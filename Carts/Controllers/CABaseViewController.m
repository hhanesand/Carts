//
//  CABaseViewController.m
//  GroceryList
//
//  Created by Hakon Hanesand on 3/4/15.

#import "CABaseViewController.h"

@implementation CABaseViewController

- (CAAnimationStack *)animationStack {
    if (!_animationStack) {
        _animationStack = [[CAAnimationStack alloc] init];
    }
    
    return _animationStack;
}

@end
