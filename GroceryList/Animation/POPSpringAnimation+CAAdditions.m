//
//  POPPropertyAnimation+GLReverse.m
//  GroceryList
//
//  Created by Hakon Hanesand on 3/4/15.

#import <ReactiveCocoa/ReactiveCocoa.h>

#import "POPSpringAnimation+GLAdditions.h"

@implementation POPSpringAnimation (GLAdditions)

- (POPSpringAnimation *)reverse {
    POPSpringAnimation *reversed = [POPSpringAnimation animationWithPropertyNamed:self.property.name];
    
    reversed.springBounciness = self.springBounciness;
    reversed.springSpeed = self.springSpeed;

    reversed.toValue = self.fromValue;
    reversed.fromValue = self.toValue;
    
    reversed.name = [NSString stringWithFormat:@"reversed_%@", self.name];
    
    return reversed;
}


@end