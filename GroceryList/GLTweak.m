//
//  GLTweaks.m
//  GroceryList
//
//  Created by Hakon Hanesand on 3/6/15.
//
//

#import "GLTweak.h"

@implementation GLTweak

- (instancetype)initWithIdentifier:(NSString *)identifier name:(NSString *)name defaultValue:(id)defaultValue stepValue:(id)stepValue andObserver:(id<FBTweakObserver>)observer {
    if (self = [super initWithIdentifier:identifier]) {
        self.name = name;
        self.defaultValue = defaultValue;
        self.stepValue = stepValue;
        [self addObserver:observer];
    }
    
    return self;
}

@end