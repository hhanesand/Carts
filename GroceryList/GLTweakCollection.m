//
//  GLTweakCollection.m
//  GroceryList
//
//  Created by Hakon Hanesand on 3/7/15.
//
//

#import "GLTweakCollection.h"
#import "GLTweak.h"

@implementation GLTweakCollection

- (instancetype)initWithName:(NSString *)name andTweakCollectionType:(GLTweakCollectionType)type {
    if (self = [super initWithName:name]) {
        [self addTweaksForCustomCollectionType:type];
    }
    
    return self;
}

- (void)addTweaksForCustomCollectionType:(GLTweakCollectionType)type {
    switch (type) {
        case GLTweakUIColor: [self addColorTweaks];
            break;
            
        case GLTWeakPOPSpringAnimation: [self addSpringTweaks];
            break;
    }
}

- (void)addColorTweaks {
    [self addTweak:[[GLTweak alloc] initWithIdentifier:identifier name:@"Red" defaultValue:@(100) andStepValue:@(5)]];
    [self addTweak:[[GLTweak alloc] initWithIdentifier:identifier name:@"Green" defaultValue:@(100) andStepValue:@(5)]];
    [self addTweak:[[GLTweak alloc] initWithIdentifier:identifier name:@"Blue" defaultValue:@(100) andStepValue:@(5)]];
}

- (void)addSpringTweaks {
    [self addTweak:[[GLTweak alloc] initWithIdentifier:identifier name:@"Mass" defaultValue:@(1) andStepValue:@(1)]];
    [self addTweak:[[GLTweak alloc] initWithIdentifier:identifier name:@"Tension" defaultValue:@(2) andStepValue:@(1)]];
    [self addTweak:[[GLTweak alloc] initWithIdentifier:identifier name:@"Friction" defaultValue:@(3) andStepValue:@(1)]];
}

@end
