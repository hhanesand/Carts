//
//  POPPropertyAnimation+GLReverse.h
//  GroceryList
//
//  Created by Hakon Hanesand on 3/4/15.
//
//

#import <POP/POP.h>

@class RACSignal;

/**
 *  Implements methods that allow the reversion of POPAnimations. This allows one to apply several animations, and then undo them
 *  later by running the exact same animation only in reverse.
 */
@interface POPSpringAnimation (Reverse)

/**
 *  Creates a new POPSpringAnimation with toValue and fromValue switched
 *
 *  @return A new POPAnimation with the same type as animationToReverse
 */
- (POPSpringAnimation *)reverse;

/**
 *  Overwrites the completion handler with one that returns a signal when the animation is done
 *
 *  @return A signal that, when subscribed to, will send a completion event upon animation completion
 */
- (RACSignal *)completionSignal;

@end
