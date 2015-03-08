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

static NSString *identifier = @"com.github.lightice11.GroceryList";

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
    [self addTweak:[[GLTweak alloc] initWithIdentifier:identifier name:@"Spring Speed" defaultValue:@(12) stepValue:@(1) andObserver:self]];
    [self addTweak:[[GLTweak alloc] initWithIdentifier:identifier name:@"Spring Bounce" defaultValue:@(12) stepValue:@(1) andObserver:self]];
    
    [self.values setObject:@(1) forKey:@"Spring Speed"];
    [self.values setObject:@(2) forKey:@"Spring Bounce"];
}

- (void)tweakDidChange:(GLTweak *)tweak {
    [self.values setObject:tweak.currentValue forKey:tweak.name];
    [self.observer tweakCollection:self didChangeTo:self.values];
}

- (NSMutableDictionary *)values {
    if (!_values) {
        _values = [NSMutableDictionary new];
    }
    
    return _values;
}

@end
