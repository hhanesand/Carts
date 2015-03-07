//
//  GLTweakCollection.h
//  GroceryList
//
//  Created by Hakon Hanesand on 3/7/15.
//
//

#import "FBTweakCollection.h"
#import "GLTweakObserver.h"

static NSString *identifier = @"com.github.lightice11.GroceryList";


@interface GLTweakCollection : FBTweakCollection

typedef NS_ENUM(NSInteger, GLTweakCollectionType) {
    GLTweakUIColor, //creates 3 tweaks, one for each color (red, green, blue)
    GLTWeakPOPSpringAnimation
};

- (instancetype)initWithName:(NSString *)name andTweakCollectionType:(GLTweakCollectionType)type;

@end
