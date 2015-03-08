//
//  GLTweakCollection.h
//  GroceryList
//
//  Created by Hakon Hanesand on 3/7/15.
//
//

#import "FBTweakCollection.h"
#import "GLTweakObserver.h"
#import <Tweaks/FBTweak.h>
#import <Tweaks/FBTweakCategory.h>
#import <Tweaks/FBTweakStore.h>

@interface GLTweakCollection : FBTweakCollection<FBTweakObserver>

typedef NS_ENUM(NSInteger, GLTweakCollectionType) {
    GLTweakUIColor, //creates 3 tweaks, one for each color (red, green, blue)
    GLTWeakPOPSpringAnimation
};

+ (void)defineTweakCollectionInCategory:(NSString *)category collection:(NSString *)collection withType:(GLTweakCollectionType)type andObserver:(id<GLTweakObserver>)observer;

@property (nonatomic) id<GLTweakObserver> observer;

@property (nonatomic) GLTweakCollectionType type;

@property (nonatomic) NSMutableDictionary *values;

- (instancetype)initWithName:(NSString *)name andTweakCollectionType:(GLTweakCollectionType)type;

@end
