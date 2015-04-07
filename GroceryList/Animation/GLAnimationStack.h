//
//  GLAnimationStack.h
//  GroceryList
//
//  Created by Hakon Hanesand on 3/28/15.

@import Foundation;

@class RACSignal;
@class POPSpringAnimation;

/**
 *  Handles a "stack" of animations that can be handled by a view controller. It allows a view controller to "push" an animation onto the stack, and then sometime later
 *  "pop" that same animation off the stack and run it in reverse to counteract the previous animation. By using such an abstraction, one doesn't have to worry about the
 *  current state of the view heirarchy, only that if all animations have been poped off the stack, then the view heirarchy is back in its original state.
 *
 *  Note that by using this class, all completion blocks from the animations that are added will be overriden.
 */
@interface GLAnimationStack : NSObject

@property (nonatomic) NSMutableArray *stack;

/**
 *  Adds an animation with the specified properties to the stack, then it adds it to the target object (starting the animation), then it reverses the animation and stores a copy
 *
 *  @param animation   The animation to save and run
 *  @param target      The target of the animation
 *  @param description A description of the animation (used for key)
 */
- (void)pushAnimation:(POPSpringAnimation *)animation withTargetObject:(id)target andDescription:(NSString *)description;

/**
 *  Pops the last animation that was added off the stack and runs the animation on its target object (in reverse)
 *
 *  @return A signal that completes once the animation completes
 */
- (RACSignal *)popAnimation;

/**
 *  Pops all animations off the stack and runs them all in reverse, returning the view heirarchy to its original state
 *
 *  @return A signal that completes once all animations complete (all animations run concurrently)
 */
- (RACSignal *)popAllAnimations;

/**
 *  Pops all animations with their target objects equal to target off the stack and runs them all in reverse
 *
 *  @param target The target object to match against
 *
 *  @return A signal that completes once all animations complete (all animations run concurrently)
 */
- (RACSignal *)popAnimationWithTargetObject:(id)target;

@end
