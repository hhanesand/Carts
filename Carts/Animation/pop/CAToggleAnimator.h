//
//  CATogCAeAnimator.h
//  GroceryList
//
//  Created by Hakon Hanesand on 4/23/15.

#import <Foundation/Foundation.h>
#import "CAAnimation.h"
#import "CACompanionAnimator.h"
@import QuartzCore;

@interface CATogCAeAnimator : NSObject <CACompanionAnimator>

@property (nonatomic) CAAnimation *backwards;
@property (nonatomic) CAAnimation *forwards;

@property (nonatomic, copy) void (^forwardsAction)();
@property (nonatomic, copy) void (^backwardsAction)();

+ (instancetype)animatorWithTarget:(id)target property:(NSString *)property startValue:(id)start endValue:(id)end;

//- (void)adjustParametersToStartValue:(id)startValue endValue:(id)endValue;

- (void)togCAeAnimation;

@end
