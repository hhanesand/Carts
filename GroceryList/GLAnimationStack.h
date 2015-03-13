//
//  GLAnimationStack.h
//  GroceryList
//
//  Created by Hakon Hanesand on 3/4/15.
//
//

#import <Foundation/Foundation.h>

@class POPPropertyAnimation;
@class RACSignal;

@interface GLAnimationStack : NSObject

@property (nonatomic) NSMutableArray *animationStack;

/**
 *  If YES, then a call to popAllAnimations will start all animations concurrently.
 */
//@property (nonatomic) BOOL shouldPopAnimationsConcurrently;

/**
 *  Push an animation onto this View Controller's Animation stack so it can be undone at a later point and add the animation to the target object
 *
 *  @param animation    The animation that has been performed. The reverse is automatically created and added to the animation stack
 *  @param targetObject The object the animation has been applied to
 *
 */
- (void)pushAnimation:(POPPropertyAnimation *)animation withTargetObject:(id)targetObject forKey:(NSString *)key;

/**
 *  Pop the animation that was most recently added off the stack. The animation is automatically started on the target object
 *
 *  @return An RACSignal that completes when all animations have been completed
 */
- (RACSignal *)popAnimation;

- (RACSignal *)popAllAnimationsWithTargetObject:(id)object;

/**
 *  Pop all animations off the stack using popAnimation.
 *  @see shouldPopAnimationsConcurrently
 *
 *  @return An RACSignal that completes when all animations have been completed
 */
- (RACSignal *)popAllAnimations;

@end