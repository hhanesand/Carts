//
//  GLAnimation.h
//  GroceryList
//
//  Created by Hakon Hanesand on 3/28/15.
//
//

#import <Foundation/Foundation.h>
#import <Pop/POP.h>

@interface GLAnimation : NSObject

@property (nonatomic) POPSpringAnimation *animation;
@property (nonatomic) NSString *identifier;
@property (nonatomic) id targetObject;

+ (GLAnimation *)animationWithSpring:(POPSpringAnimation *)animation description:(NSString *)description targetObject:(id)targetObject;

- (void)startAnimation;

@end
