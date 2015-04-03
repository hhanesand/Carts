//
//  POPPropertyAnimation+GLReverse.m
//  GroceryList
//
//  Created by Hakon Hanesand on 3/4/15.
//
//

#import "POPSpringAnimation+GLAdditions.h"
#import "POPSpringAnimation.h"
#import "PopBasicAnimation.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation POPSpringAnimation (GLAdditions)

- (POPSpringAnimation *)reverse {
    POPSpringAnimation *reversed = [POPSpringAnimation animationWithPropertyNamed:self.property.name];
    
    reversed.springBounciness = self.springBounciness;
    reversed.springSpeed = self.springSpeed;

    reversed.toValue = self.fromValue;
    reversed.fromValue = self.toValue;
    
    return reversed;
}


@end
