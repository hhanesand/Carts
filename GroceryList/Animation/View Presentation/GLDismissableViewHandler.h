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

@interface GLDismissableViewHandler : NSObject <UIGestureRecognizerDelegate>

@property (nonatomic) id<GLDismissableHandlerDelegate> delegate;
@property (nonatomic) BOOL enabled;

- (instancetype)initWithView:(UIView *)view;

- (void)handlePan:(UIPanGestureRecognizer *)pan;

@end
