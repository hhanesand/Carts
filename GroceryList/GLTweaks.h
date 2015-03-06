//
//  GLTeaks.h
//  GroceryList
//
//  Created by Hakon Hanesand on 3/6/15.
//
//

#import <Foundation/Foundation.h>
#import <Tweaks/FBTweak.h>
#import "GLTweakObserver.h"

@class FBTweak;
@class FBTweakCategory;
@class FBTweakCollection;

/**
 *  Defines an extention to the Tweaks library designed to facilitate custom tweaks. For example, one can create a UIColor tweak and this class
 *  will generate 3 tweaks, one for each color component. It also is able to send notifications when any of the values change.
 */
@interface GLTweaks : NSObject<FBTweakObserver>

typedef NS_ENUM(NSInteger, GLTweaksType) {
    GLTweakUIColor //creates 3 tweaks, one for each color (red, green, blue)
};

/**
 *  @return The shared instance. Use this instead of alloc init.
 */
+ (GLTweaks *)sharedInstance;

/**
 *  Creates and returns a FBTweakCollection that contains FBTweaks based on the Tweak type (@see GLTweaksType)
 *
 *  @param category   Name of the category
 *  @param collection Name of the collection
 *  @param type       Type of Tweak
 *  @param observer   The callback for the FBTweakCollection, must implement GLTweakObserver (@see GLTweakObserver)
 *
 *  @return The new FBTweakCollection
 */
- (FBTweakCollection *)tweakCollectionWithCategoryName:(NSString *)category collectionName:(NSString *)collection tweakType:(GLTweaksType)type andObserver:(id<GLTweakObserver>)observer;

@end