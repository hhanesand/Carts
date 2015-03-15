//
//  GLTransition.h
//  GroceryList
//
//  Created by Hakon Hanesand on 3/13/15.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class RACSubject;

/**
 *  Implements a transition between two view controllers without any animation
 */
@interface GLTransition : NSObject<UIViewControllerAnimatedTransitioning>

/**
 *  Indicates whether the transition is presenting or dismissing views
 */
@property (nonatomic, getter=isPresenting) BOOL presenting;

+ (instancetype)transitionWithPresentation:(BOOL)isPresenting;

@end
