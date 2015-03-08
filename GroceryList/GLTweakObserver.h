//
//  GLTweakObserver.h
//  GroceryList
//
//  Created by Hakon Hanesand on 3/6/15.
//
//

#import <Foundation/Foundation.h>

@class GLTweakCollection;

@protocol GLTweakObserver <NSObject>

- (void)tweakCollection:(GLTweakCollection *)collection didChangeTo:(NSDictionary *)values;

@end
