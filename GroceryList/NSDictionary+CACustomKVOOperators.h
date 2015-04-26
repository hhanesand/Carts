//
//  NSDictionary+GLCustomKVOOperators.h
//  GroceryList
//
//  Created by Hakon Hanesand on 4/9/15.

@import Foundation;

@interface NSDictionary (GLCustomKVOOperators)

/**
 *  Defines a custom KVO path using a bit of trickery. Allows the use of @first inside a valueForKeyPath: call on a dictionary to extract the first item in an array at the keypath
 *  Based off this article http://funwithobjc.tumblr.com/post/1527111790/defining-custom-key-path-operators
 *
 *  @param keypath The keypath of the array
 *
 *  @return The first object in the array at the specifed keypath
 */
- (id)_firstForKeyPath:(NSString *)keypath;

@end
