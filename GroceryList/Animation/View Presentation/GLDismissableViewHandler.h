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
 *  Initializes a draggable view hander with a layout constraint and the height of its animatable view
 *
 *  @param height     The  height of the animatable view
 *  @param constraint The constraint the handler should animate to move the view up and down
 *
 */
- (instancetype)initWithHeightOfAnimatableView:(CGFloat)height animatableConstraint:(NSLayoutConstraint *)constraint;

/**
 *  Call this method when the UIPanGestureRecognizer's target method is called, or provide this method as it's target
 *
 *  @param pan The pan gesture recognizer
 */
- (void)handlePan:(UIPanGestureRecognizer *)pan;

- (RACSignal *)dismissViewWithVelocity:(CGFloat)velocity;
- (RACSignal *)presentViewWithVelocity:(CGFloat)velocity;

@end
