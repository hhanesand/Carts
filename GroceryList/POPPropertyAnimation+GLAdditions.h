//
//  POPPropertyAnimation+GLReverse.h
//  GroceryList
//
//  Created by Hakon Hanesand on 3/4/15.
//
//

#import "POPPropertyAnimation.h"

@class RACSignal;

/**
 *  Implements methods that allow the reversion of POPAnimations. This allows one to apply several animations, and then undo them
 *  later by running the exact same animation only in reverse.
 */
@interface POPPropertyAnimation (Reverse)

/**
 *  Creates a new POPAnimation with toValue and fromValue switched
 *
 *  @param animationToReverse The animation to reverse, currently supports POPSpringAnimation and POPBasicAnimation
 *
 *  @return A new POPAnimation with the same type as animationToReverse
 */
+ (POPPropertyAnimation *)reverseAnimation:(POPPropertyAnimation *)animationToReverse;

/**
 *  Overwrites the completion handler to return a signal when the animation is done
 *
 *  @return The cold RACSignal that will send the events, one next followed by a complete signal
 */
- (RACSignal *)addRACSignalToAnimation;

@end
