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

+ (GLTransition *)transition {
    return [[self alloc] init];
}

- (void)animateTransitionWithContext:(GLTransitioningContext *)context {
    [context.containerView addSubview:context.toViewController.view];
    [self.completionSignal sendCompleted];
}

- (RACSubject *)completionSignal {
    if (!_completionSignal) {
        _completionSignal = [RACSubject subject];
    }
    
    return _completionSignal;
}

@end
