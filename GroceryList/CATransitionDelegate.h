//
//  GLTransitionDelegate.h
//  GroceryList
//
//  Created by Hakon Hanesand on 4/13/15.

@import Foundation;
@import UIKit;

@interface GLTransitionDelegate : NSObject <UIViewControllerTransitioningDelegate>

/**
 *  Creates a GLTransitionDelegate that implements UIViewControllerTransitioningDelegate with the provided objects
 *
 *  @param controller             The controller that is the presented controller
 *  @param presentationController The class of the presentation controller (must subclass UIPresentationController)
 *  @param transitionManager      The class of the animation (must conform to UIViewControllerAnimatedTransitioning and GLReversibleTransition
 */
- (instancetype)initWithController:(id)controller presentationController:(Class)presentationController transitionManager:(Class)transitionManager;

@end
