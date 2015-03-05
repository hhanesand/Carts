//
//  GLAnimationStore.m
//  GroceryList
//
//  Created by Hakon Hanesand on 3/4/15.
//
//

#import "GLAnimationStore.h"

@implementation GLAnimationStore

+ (GLAnimationStore *)objectWithAnimation:(POPPropertyAnimation *)animation onTargetObject:(id)targetObject {
    return [[GLAnimationStore alloc] initWithAnimation:animation onTargetObject:targetObject];
}

- (instancetype)initWithAnimation:(POPPropertyAnimation *)animation onTargetObject:(id)targetObject {
    if (self = [super init]) {
        self.animation = animation;
        self.targetObject = targetObject;
    }
    
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Anim %@ Object %@", self.animation, self.targetObject];
}
@end
