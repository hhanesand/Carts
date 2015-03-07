//
//  GLTweaks.m
//  GroceryList
//
//  Created by Hakon Hanesand on 3/6/15.
//
//

#import "GLTweak.h"

@implementation GLTweak

- (instancetype)initWithIdentifier:(NSString *)identifier name:(NSString *)name defaultValue:(id)defaultValue andStepValue:(id)stepValue {
    if (self = [super initWithIdentifier:identifier]) {
        self.name = name;
        self.defaultValue = defaultValue;
        self.stepValue = stepValue;
    }
    
    return self;
}

@end