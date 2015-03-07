//
//  GLTeaks.h
//  GroceryList
//
//  Created by Hakon Hanesand on 3/6/15.
//
//

#import <Tweaks/FBTweak.h>

@interface GLTweak : FBTweak

- (instancetype)initWithIdentifier:(NSString *)identifier name:(NSString *)name defaultValue:(id)defaultValue andStepValue:(id)stepValue;

@end