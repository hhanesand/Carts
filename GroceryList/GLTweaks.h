//
//  GLTeaks.h
//  GroceryList
//
//  Created by Hakon Hanesand on 3/6/15.
//
//

#import <Foundation/Foundation.h>
#import <Tweaks/FBTweak.h>

@class FBTweak;
@class FBTweakCategory;
@class FBTweakCollection;

@interface GLTweaks : NSObject<FBTweakObserver>

typedef NS_ENUM(NSInteger, GLTweaksType) {
    GLTweakUIColor //creates 3 tweaks, one for each color (red, green, blue)
};

/**
 *  @return The shared instance. Use this instead of alloc init.
 */
+ (GLTweaks *)sharedInstance;

/**
 *  Creates and returns a FBTweak
 *
 *  @param category   The category name of the Tweak
 *  @param collection The collection name of the Tweak
 *  @param name       The name of the Tweak
 *  @param value      The default value of the Tweak
 *  @param observer   The observer
 *
 *  @return The new FBTweak
 */
- (FBTweak *)tweakWithCategoryName:(NSString *)category collectionName:(NSString *)collection name:(NSString *)name defaultValue:(id)value andObserver:(id<FBTweakObserver>)observer;

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
- (FBTweakCollection *)tweakCollectionWithCategoryName:(NSString *)category collectionName:(NSString *)collection tweakType:(GLTweaksType)type andObserver:(id<FBTweakObserver>)observer;

/**
 *  Gets the FBTweakCategory with the specified name, or creates it if it is nil
 *
 *  @param name Name of the category
 *
 *  @return The category that has been fetched or created
 */
- (FBTweakCategory *)tweakCategoryWithName:(NSString *)name;

@end