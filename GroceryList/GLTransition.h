//
//  GLTransition.h
//  GroceryList
//
//  Created by Hakon Hanesand on 3/13/15.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GLTransitioningContext.h"

@class RACSubject;

/**
 *  Implements a transition between two view controllers without any animation
 */
@interface GLTransition : NSObject

+ (instancetype)transition;

- (void)animateTransitionWithContext:(GLTransitioningContext *)context;

@property (nonatomic) RACSubject *completionSignal;

@end
