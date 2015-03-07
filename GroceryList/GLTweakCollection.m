//
//  GLTweakCollection.m
//  GroceryList
//
//  Created by Hakon Hanesand on 3/7/15.
//
//

#import "GLTweakCollection.h"
#import "GLTweak.h"

#import "UIColor+GLColor.h"
#import <pop/POPSpringAnimation.h>

@implementation GLTweakCollection

+ (void)defineTweakCollectionInCategory:(NSString *)categoryName collection:(NSString *)collectionName withType:(GLTweakCollectionType)type andObserver:(id<GLTweakObserver>)observer {
    FBTweakCategory *category = [GLTweakCollection tweakCategoryWithName:categoryName];
    
    GLTweakCollection *collection = [[GLTweakCollection alloc] initWithName:collectionName andTweakCollectionType:type];
    collection.observer = observer;

    [category addTweakCollection:collection];
}

+ (FBTweakCategory *)tweakCategoryWithName:(NSString *)name {
    FBTweakStore *store = [FBTweakStore sharedInstance];
    FBTweakCategory *category = [store tweakCategoryWithName:name];
    
    if (!category) {
        [store addTweakCategory:[[FBTweakCategory alloc] initWithName:name]];
        return [store tweakCategoryWithName:name];
    }
    
    return category;
}

- (instancetype)initWithName:(NSString *)name andTweakCollectionType:(GLTweakCollectionType)type {
    if (self = [super initWithName:name]) {
        self.type = type;
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
    [self addTweak:[[GLTweak alloc] initWithIdentifier:identifier name:@"Red" defaultValue:@(100) stepValue:@(5) andObserver:self]];
    [self addTweak:[[GLTweak alloc] initWithIdentifier:identifier name:@"Green" defaultValue:@(100) stepValue:@(5) andObserver:self]];
    [self addTweak:[[GLTweak alloc] initWithIdentifier:identifier name:@"Blue" defaultValue:@(100) stepValue:@(5) andObserver:self]];
    
    [self.values setObject:@(100) forKey:@"Red"];
    [self.values setObject:@(100) forKey:@"Green"];
    [self.values setObject:@(100) forKey:@"Blue"];
}

- (void)addSpringTweaks {
    [self addTweak:[[GLTweak alloc] initWithIdentifier:identifier name:@"Mass" defaultValue:@(1) stepValue:@(1) andObserver:self]];
    [self addTweak:[[GLTweak alloc] initWithIdentifier:identifier name:@"Tension" defaultValue:@(2) stepValue:@(1) andObserver:self]];
    [self addTweak:[[GLTweak alloc] initWithIdentifier:identifier name:@"Friction" defaultValue:@(3) stepValue:@(1) andObserver:self]];
    
    [self.values setObject:@(1) forKey:@"Mass"];
    [self.values setObject:@(2) forKey:@"Tension"];
    [self.values setObject:@(3) forKey:@"Friction"];
}

- (void)tweakDidChange:(GLTweak *)tweak {
    [self.values setObject:tweak.currentValue forKey:tweak.name];
    [self.observer tweakCollection:self didChangeTo:[self valueForTweakType]];
}

- (id)valueForTweakType {
    switch (self.type) {
        case GLTweakUIColor:
            return [self getColorValue];

        case GLTWeakPOPSpringAnimation:
            return [self getSpringAnimationValue];
    }
}

- (UIColor *)getColorValue {
    return [UIColor colorWithRed:[[self.values valueForKey:@"Red"] floatValue] green:[[self.values valueForKey:@"Green"] floatValue] blue:[[self.values valueForKey:@"Blue"] floatValue]];
}

- (POPSpringAnimation *)getSpringAnimationValue {
    return nil;
}

- (NSMutableDictionary *)values {
    if (!_values) {
        _values = [NSMutableDictionary new];
    }
    
    return _values;
}

@end
