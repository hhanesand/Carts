//
//  GLAnimation.m
//  GroceryList
//
//  Created by Hakon Hanesand on 3/28/15.

#import "GLAnimation.h"

@implementation GLAnimation

+ (GLAnimation *)animationWithSpring:(POPSpringAnimation *)ani description:(NSString *)description targetObject:(id)targetObject {
    GLAnimation *animation = [[GLAnimation alloc] init];
    animation.animation = ani;
    animation.identifier = description;
    animation.targetObject = targetObject;
    return animation;
}

- (void)startAnimation {
    [self.targetObject pop_addAnimation:self.animation forKey:self.description];
}

@end
