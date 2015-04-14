//
//  GLDismissableViewHandler.h
//  GroceryList
//
//  Created by Hakon Hanesand on 4/2/15.

@import Foundation;
@import UIKit;

@protocol GLDismissableHandlerDelegate <NSObject>

@optional
- (void)didPresentViewAfterUserInteraction;
- (void)didDismissViewAfterUserInteraction;
- (void)willPresentViewAfterUserInteraction;
- (void)willDismissViewAfterUserInteraction;

@end

/**
 *  Handles a view that can be dismissed by pulling downwards. (mimics the control center)
 */
@interface GLDismissableViewHandler : NSObject <UIGestureRecognizerDelegate>

@property (nonatomic) id<GLDismissableHandlerDelegate> delegate;
@property (nonatomic) BOOL enabled;

/**
 *  Initializes with the specified view as it's target view (the view that is draggable) and its final position
 *
 *  @param view The view that is draggable
 *  @param finalPosition The final center position of the view when it is presented
 *
 *  @return A new GLDismissableViewHandler
 */
- (instancetype)initWithView:(UIView *)view finalPosition:(CGFloat)finalPosition;

/**
 *  Call this method when the UIPanGestureRecognizer's target method is called, or provide this method as it's target
 *
 *  @param pan The pan gesture recognizer
 */
- (void)handlePan:(UIPanGestureRecognizer *)pan;

- (RACSignal *)dismissViewWithVelocity:(CGFloat)velocity;
- (RACSignal *)presentViewWithVelocity:(CGFloat)velocity;

@end
