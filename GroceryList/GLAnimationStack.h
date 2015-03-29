//
//  GLAnimationStack.h
//  GroceryList
//
//  Created by Hakon Hanesand on 3/28/15.
//
//

#import <Foundation/Foundation.h>

@class RACSignal;
@class POPSpringAnimation;

@interface GLAnimationStack : NSObject

@property (nonatomic) NSMutableArray *stack;

- (void)pushAnimation:(POPSpringAnimation *)animation withTargetObject:(id)target andDescription:(NSString *)description;

- (RACSignal *)popAnimation;
- (RACSignal *)popAllAnimations;
- (RACSignal *)popAnimationWithTargetObject:(id)target;

@end
