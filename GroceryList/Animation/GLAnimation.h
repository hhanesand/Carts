//
//  GLAnimation.h
//  GroceryList
//
//  Created by Hakon Hanesand on 3/28/15.

#import <Pop/POP.h>

@import Foundation;

/**
 *  Stores a POPSpringAnimation for reuse later
 */
@interface GLAnimation : NSObject

@property (nonatomic) POPSpringAnimation *animation;
@property (nonatomic) NSString *identifier;
@property (nonatomic) id targetObject;

/**
 *  Construct a GLAnimation with these parameters
 *
 *  @param animation    The animation to save
 *  @param description  The description of the animation (used for animation key)
 *  @param targetObject The target object for this animation
 *
 *  @return A new GLAnimation with all properties set
 */
+ (GLAnimation *)animationWithSpring:(POPSpringAnimation *)animation description:(NSString *)description targetObject:(id)targetObject;

+ (GLAnimation *)animationWithTargetObject:(id)targetObject property:(NSString *)property;

/**
 *  Adds the stored Spring Animation to the stored target object
 */
- (void)startAnimation;

@end
