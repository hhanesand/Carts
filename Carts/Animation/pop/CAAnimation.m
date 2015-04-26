//
//  CAAnimation.m
//  GroceryList
//
//  Created by Hakon Hanesand on 3/28/15.

#import "CAAnimation.h"

@implementation CAAnimation

+ (CAAnimation *)animationWithSpring:(POPSpringAnimation *)ani description:(NSString *)description targetObject:(id)targetObject {
    CAAnimation *animation = [[CAAnimation alloc] init];
    animation.animation = ani;
    animation.identifier = description;
    animation.targetObject = targetObject;
    return animation;
}

+ (CAAnimation *)animationWithTargetObject:(id)targetObject property:(NSString *)property {
    return [self animationWithSpring:[self defaultSpringWithProperty:property] description:@"" targetObject:targetObject];
}

+ (POPSpringAnimation *)defaultSpringWithProperty:(NSString *)property {
    POPSpringAnimation *spring = [POPSpringAnimation animationWithPropertyNamed:property];
    spring.springSpeed = 15;
    spring.springBounciness = 15;
    return spring;
}

- (void)startAnimation {
    [self.targetObject pop_addAnimation:self.animation forKey:self.description];
}

@end
