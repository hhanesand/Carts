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

+ (GLAnimationStore *)objectWithAnimation:(POPPropertyAnimation *)animation onTargetObject:(id)targetObject;

@property (nonatomic, weak) POPPropertyAnimation *animation;
@property (nonatomic, weak) id targetObject;

- (instancetype)initWithAnimation:(POPPropertyAnimation *)animation onTargetObject:(id)targetObject;

@end