//
//  POPAnimation+GLAnimation.h
//  GroceryList
//
//  Created by Hakon Hanesand on 4/3/15.

#import <POP/POP.h>

@class RACSignal;

@interface POPAnimation (GLAnimation)

/**
 *  Overwrites the completion handler with one that returns a signal when the animation is done
 *
 *  @return A signal that, when subscribed to, will send a completion event upon animation completion
 */
- (RACSignal *)completionSignal;

@end
