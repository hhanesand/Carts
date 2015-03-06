//
//  GLTweaks.m
//  GroceryList
//
//  Created by Hakon Hanesand on 3/6/15.
//
//

#import "GLTweaks.h"
#import "GLTweakObserver.h"
#import "UIColor+GLColor.h"

#import <Tweaks/FBTweakStore.h>
#import <Tweaks/FBTweakCategory.h>
#import <Tweaks/FBTweakCollection.h>

@interface GLTweaks()
@property (nonatomic) NSMutableDictionary *customCollections;
@end

@implementation GLTweaks

static NSString *identifier = @"com.github.lightice11.GroceryList";

+ (instancetype)sharedInstance
{
    static GLTweaks *sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - Tweak Creation

- (FBTweakCollection *)tweakCollectionWithCategoryName:(NSString *)category collectionName:(NSString *)collection tweakType:(GLTweaksType)type andObserver:(id<GLTweakObserver>)observer {
    switch (type) {
        case GLTweakUIColor:
            return [self colorTweakWithCategoryName:category collectionName:collection andObserver:observer];
    }
}

- (FBTweakCollection *)colorTweakWithCategoryName:(NSString *)category collectionName:(NSString *)collectionName andObserver:(id<GLTweakObserver>)observer {
    [self tweakWithCategoryName:category collectionName:collectionName name:@"Red" defaultValue:@(100)];
    [self tweakWithCategoryName:category collectionName:collectionName name:@"Blue" defaultValue:@(100)];
    [self tweakWithCategoryName:category collectionName:collectionName name:@"Green" defaultValue:@(100)];
    
    FBTweakCollection *collection = [self tweakCollectionWithName:collectionName forCategoryName:category];
    [self.customCollections setValue:collection forKey:collectionName];
    return collection;
}

- (FBTweak *)tweakWithCategoryName:(NSString *)categoryName collectionName:(NSString *)collectionName name:(NSString *)name defaultValue:(id)value {
    FBTweak *tweak = [[FBTweak alloc] initWithIdentifier:identifier];
    tweak.name = name;
    tweak.defaultValue = value;
    
    FBTweakCategory *category = [self tweakCategoryWithName:categoryName];
    FBTweakCollection *collection = [self tweakCollectionWithName:collectionName forCategory:category];
    [collection addTweak:tweak];
    
    [tweak addObserver:self];
    return tweak;
}

#pragma mark - Tweak Notifications

- (void)tweakDidChange:(FBTweak *)tweak {
    FBTweakCollection *collection = [self collectionForTweak:tweak];
    id<GLTweakObserver> observer = self.customCollections[collection];
    [observer tweakCollectionDidChange:[self getValueForCustomCollection:collection]];
}

- (id)getValueForCustomCollection:(FBTweakCollection *)collection {
    if ([collection.tweaks count] == 3) {
        int red = 0;
        int blue = 0;
        int green = 0;
        
        for (FBTweak *tweak in collection.tweaks) {
            if ([tweak.name isEqualToString:@"Red"]) {
                red = [tweak.currentValue intValue];
            } else if ([tweak.name isEqualToString:@"Green"]) {
                green = [tweak.currentValue intValue];
            } else if ([tweak.name isEqualToString:@"Blue"]) {
                blue = [tweak.currentValue intValue];
            }
        }
        
        return [UIColor r:red g:green b:blue];
    }
    
    NSAssert(false, @"Failed to provide custom value for collection %@", collection);
    return nil;
}

#pragma mark - Helper Acessor Methods

- (FBTweakCategory *)tweakCategoryWithName:(NSString *)name {
    FBTweakStore *store = [FBTweakStore sharedInstance];
    FBTweakCategory *category = [store tweakCategoryWithName:name];
    
    if (!category) {
        [store addTweakCategory:[[FBTweakCategory alloc] initWithName:name]];
        return [store tweakCategoryWithName:name];
    }
    
    return category;
}

- (FBTweakCollection *)tweakCollectionWithName:(NSString *)name forCategory:(FBTweakCategory *)category {
    FBTweakCollection *collection = [category tweakCollectionWithName:name];
    
    if (!collection) {
        [category addTweakCollection:[[FBTweakCollection alloc] initWithName:name]];
        return [category tweakCollectionWithName:name];
    }
    
    return collection;
}

- (FBTweakCollection *)tweakCollectionWithName:(NSString *)name forCategoryName:(NSString *)categoryName {
    FBTweakStore *store = [FBTweakStore sharedInstance];
    return [[store tweakCategoryWithName:categoryName] tweakCollectionWithName:name];
}

- (FBTweakCollection *)collectionForTweak:(FBTweak *)tweak {
    for (FBTweakCategory *category in [FBTweakStore sharedInstance].tweakCategories) {
        for (FBTweakCollection *collection in category.tweakCollections) {
            if ([collection.tweaks containsObject:tweak]) {
                return collection;
            }
        }
    }
    
    NSAssert(false, @"Failed to find collection for Tweak %@", tweak);
    return nil;
}

- (NSMutableDictionary *)customCollections {
    if (!_customCollections) {
        _customCollections = [NSMutableDictionary new];
    }
    
    return _customCollections;
}

@end