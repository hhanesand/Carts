//
//  POPPropertyAnimation+GLReverse.m
//  GroceryList
//
//  Created by Hakon Hanesand on 3/4/15.
//
//

#import "POPPropertyAnimation+GLAdditions.h"
#import "POPSpringAnimation.h"
#import "PopBasicAnimation.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation POPPropertyAnimation (GLAdditions)

+ (POPPropertyAnimation *)reverseAnimation:(POPPropertyAnimation *)animationToReverse {
    if (![animationToReverse isKindOfClass:[POPSpringAnimation class]] && ![animationToReverse isKindOfClass:[POPBasicAnimation class]]) {
        NSLog(@"animationToReverse must be either a Spring or Basic Animation.");
    }
    
    if ([animationToReverse isKindOfClass:[POPSpringAnimation class]]) {
        POPSpringAnimation *springAnimationToReverse = (POPSpringAnimation *)animationToReverse;
        POPSpringAnimation *reverseSpringAnimation = [POPSpringAnimation animationWithPropertyNamed:springAnimationToReverse.property.name];
        
        reverseSpringAnimation.springBounciness = springAnimationToReverse.springBounciness;
        reverseSpringAnimation.springSpeed = springAnimationToReverse.springSpeed;
        reverseSpringAnimation.dynamicsFriction = springAnimationToReverse.dynamicsFriction;
        reverseSpringAnimation.dynamicsMass = springAnimationToReverse.dynamicsMass;
        reverseSpringAnimation.dynamicsTension = springAnimationToReverse.dynamicsTension;
        

        reverseSpringAnimation.toValue = springAnimationToReverse.fromValue;
        reverseSpringAnimation.fromValue = springAnimationToReverse.toValue;
        
        return reverseSpringAnimation;
    } else {
        POPBasicAnimation *basicAnimationToReverse = (POPBasicAnimation *)animationToReverse;
        POPBasicAnimation *reverseBasicAnimation = [POPBasicAnimation animationWithPropertyNamed:basicAnimationToReverse.property.name];
        
        reverseBasicAnimation.duration = basicAnimationToReverse.duration;
        reverseBasicAnimation.timingFunction = basicAnimationToReverse.timingFunction;
        
        reverseBasicAnimation.toValue = basicAnimationToReverse.fromValue;
        reverseBasicAnimation.fromValue = basicAnimationToReverse.toValue;
        
        return reverseBasicAnimation;
    }
}

- (RACSignal *)addRACSignalToAnimation {
    RACSubject *completion = [RACSubject subject];
    
    self.completionBlock = ^(POPAnimation *animation, BOOL done) {
        if (done) {
            [completion sendNext:[RACTupleNil tupleNil]];
            [completion sendCompleted];
        }
    };
    
    return completion;
}

- (void)dealloc {
    NSLog(@"Fishy");
}


@end
