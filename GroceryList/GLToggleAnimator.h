//
//  GLToggleAnimator.h
//  GroceryList
//
//  Created by Hakon Hanesand on 4/23/15.

#import <Foundation/Foundation.h>
#import "GLAnimation.h"
@import QuartzCore;

@interface GLToggleAnimator : NSObject

@property (nonatomic) GLAnimation *backwards;
@property (nonatomic) GLAnimation *forwards;

+ (instancetype)animatorWithTarget:(id)target property:(NSString *)property startValue:(id)start endValue:(id)end;

//- (void)adjustParametersToStartValue:(id)startValue endValue:(id)endValue;

- (void)performAlongsideForwardAnimation:(void (^)())action;
- (void)performAlongsideBackwardAnimation:(void (^)())action;

- (void)toggleAnimation;

@end
