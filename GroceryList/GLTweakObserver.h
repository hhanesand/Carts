//
//  GLTweakObserver.h
//  GroceryList
//
//  Created by Hakon Hanesand on 3/6/15.
//
//

#import <Foundation/Foundation.h>

@class FBTweakCollection;

@protocol GLTweakObserver <NSObject>

- (void)tweakCollectionDidChange:(FBTweakCollection *)collection;

@end
