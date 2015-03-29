//
//  GLTweakObserver.h
//  GroceryList
//
//  Created by Hakon Hanesand on 3/6/15.
//
//

@import Foundation;

@class GLTweakCollection;

@protocol GLTweakObserver <NSObject>

/**
 *  The method that is called every time a tweak in a tweak collection is changed
 *
 *  @param collection The collection that changed
 *  @param values     A dictionary that contains the values of the tweaks, with the keys as the names of the tweaks
 */
- (void)tweakCollection:(GLTweakCollection *)collection didChangeTo:(NSDictionary *)values;

@end
