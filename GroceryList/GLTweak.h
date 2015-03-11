//
//  GLTeaks.h
//  GroceryList
//
//  Created by Hakon Hanesand on 3/6/15.
//
//

#import <Tweaks/FBTweak.h>

@interface GLTweak : FBTweak

/**
 *  Creates a tweak
 *
 *  @param identifier   The identifier for this tweak
 *  @param name         The name of this tweak, displayed on the UI
 *  @param defaultValue The default value, also set to the current value
 *  @param stepValue    The step value
 *  @param observer     The observer for this tweak
 *
 *  @return <#return value description#>
 */
- (instancetype)initWithIdentifier:(NSString *)identifier name:(NSString *)name defaultValue:(id)defaultValue stepValue:(id)stepValue andObserver:(id<FBTweakObserver>)observer;

@end