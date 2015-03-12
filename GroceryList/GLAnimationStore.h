//
//  GLAnimationStore.h
//  GroceryList
//
//  Created by Hakon Hanesand on 3/4/15.
//
//

#import <Foundation/Foundation.h>
#import <pop/POP.h>

@interface GLAnimationStore : NSObject

/**
 *  Creates and returns a GLAnimationStore
 *
 *  @param animation    The animation
 *  @param targetObject The target
 *
 *  @return The new GLAnimationStore
 */
+ (GLAnimationStore *)objectWithAnimation:(POPPropertyAnimation *)animation onTargetObject:(id)targetObject;

/**
 *  The animation
 */
@property (nonatomic) POPPropertyAnimation *animation;

/**
 *  The object this animation should be applied to
 */
@property (nonatomic) id targetObject;

@end