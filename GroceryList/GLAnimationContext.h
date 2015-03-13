//
//  GLAnimationContext.h
//  GroceryList
//
//  Created by Hakon Hanesand on 3/12/15.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GLTransition.h"

/**
 *  A class that manages animations to and from view controllers on the screen
 *  Slight duplication of UINavigationViewController functionality, but without the restrictions by Apple
 */
@interface GLAnimationContext : NSObject

/**
 *  The stack that stores view controllers that have been animated onto the screen at some point
 */
@property (nonatomic) NSMutableArray *stack;

/**
 *  The index of the view controller currently being displayed
 */
@property (nonatomic) NSUInteger index;

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController;

- (void)pushViewController:(UIViewController *)viewController withTransition:(GLTransition *)transition;

- (void)popViewControllerView:(UIViewController *)viewController withTransition:(GLTransition *)transition;

@end
