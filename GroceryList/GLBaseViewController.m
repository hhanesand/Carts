//
//  GLBaseViewController.m
//  GroceryList
//
//  Created by Hakon Hanesand on 3/4/15.
//
//

#import "GLBaseViewController.h"

@implementation GLBaseViewController

- (GLAnimationStack *)animationStack {
    if (!_animationStack) {
        _animationStack = [GLAnimationStack new];
    }
    
    return _animationStack;
}

@end