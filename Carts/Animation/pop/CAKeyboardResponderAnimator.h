//
//  CAKeyboardResponderAnimator.h
//  GroceryList
//
//  Created by Hakon Hanesand on 4/13/15.

@import Foundation;
@import UIKit;

@protocol CAKeyboardMovementResponderDelegate <NSObject>

/**
 *  Return the frame for the UI Element that is being interacted with by the user (usually a UITextField or UITextView)
 *
 *  @return The frame
 */
- (UIView *)viewForActiveUserInputElement;

/**
 *  Return the view that should be animated to adjust to the keyboard appearing
 */
- (UIView *)viewToAnimateForKeyboardAdjustment;

- (NSLayoutConstraint *)layoutConstraintForAnimatingView;

@end

@interface CAKeyboardResponderAnimator : NSObject

- (instancetype)initWithDelegate:(id<CAKeyboardMovementResponderDelegate>)delegate;

@end
