//
//  GLAnimationStack.m
//  GroceryList
//
//  Created by Hakon Hanesand on 3/4/15.
//
//

#import "GLAnimationStack.h"
#import "GLAnimationStore.h"
#import <pop/POP.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "POPPropertyAnimation+GLAdditions.h"

@implementation GLAnimationStack

- (instancetype)init {
    if (self = [super init]) {
        self.animationStack = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)pushAnimation:(POPPropertyAnimation *)anim withTargetObject:(id)targetObject forKey:(NSString *)key {
    GLAnimationStore *animation = [GLAnimationStore objectWithAnimation:[POPPropertyAnimation reverseAnimation:anim] onTargetObject:targetObject];
    [self.animationStack addObject:animation];
    [targetObject pop_addAnimation:anim forKey:key];
    NSLog(@"%@", self.animationStack);
}

- (RACSignal *)popAnimation {
    GLAnimationStore *reverseAnimation = [self.animationStack lastObject];
    [self.animationStack removeLastObject];
    
    RACSignal *completion = [reverseAnimation.animation addRACSignalToAnimation];
    [reverseAnimation.targetObject pop_addAnimation:reverseAnimation.animation forKey:@"reverseAnimation"];
    return completion;
}

- (RACSignal *)popAllAnimations {
    NSMutableArray *signals = [NSMutableArray new];
    
    while ([self.animationStack count] != 0) {
        [signals addObject:[self popAnimation]];
    }
    
    NSLog(@"HI!");
    
    return [[RACSignal combineLatest:signals] map:^id(id x) {
        return @(YES);
    }];
}

@end