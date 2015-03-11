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

/**
 *  Defines several premade tweak collections that can be observed
 */
typedef NS_ENUM(NSInteger, GLTweakCollectionType){
    /**
     *  Creates 3 tweaks named Red, Green, and Blue, all numbers ranging from 0-255 with 100 as the default value
     */
    GLTweakUIColor,
    
    /**
     *  Creates 2 tweaks, named Spring Speed and Spring Tension, both numbers ranging from 0-20 with 12 as the default value
     */
    GLTWeakPOPSpringAnimation
};

/**
 *  Define a tweak collection containing tweaks governed by the collection type passed in
 *  This method only defines a new category if one with the same name does not exist
 *
 *  @param category   The category name for this new collection to reside in
 *  @param collection The collection name for this new collection
 *  @param type       The type of this collection (@see GLTweakCollectionType)
 *  @param observer   The observer for this collection
 */
+ (void)defineTweakCollectionInCategory:(NSString *)category collection:(NSString *)collection withType:(GLTweakCollectionType)type andObserver:(id<GLTweakObserver>)observer;

/**
 *  The observer that gets notified of any changes of its child tweaks
 */
@property (nonatomic) id<GLTweakObserver> observer;


/**
 *  The type of this collection
 *  @see GLTweakCollectionType
 */
@property (nonatomic) GLTweakCollectionType type;

/**
 *  The current values of the child tweaks, keys are the names of the tweaks
 */
@property (nonatomic) NSMutableDictionary *values;

@end
