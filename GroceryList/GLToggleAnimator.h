//
//  GLToggleAnimator.h
//  GroceryList
//
//  Created by Hakon Hanesand on 4/23/15.

#import <Foundation/Foundation.h>
#import "GLAnimation.h"
#import "GLCompanionAnimator.h"
@import QuartzCore;

@interface GLToggleAnimator : NSObject <GLCompanionAnimator>

@property (nonatomic) GLAnimation *backwards;
@property (nonatomic) GLAnimation *forwards;

@property (nonatomic, copy) void (^forwardsAction)();
@property (nonatomic, copy) void (^backwardsAction)();

+ (instancetype)animatorWithTarget:(id)target property:(NSString *)property startValue:(id)start endValue:(id)end;

//- (void)adjustParametersToStartValue:(id)startValue endValue:(id)endValue;

- (void)toggleAnimation;

@end
