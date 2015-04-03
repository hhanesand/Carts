//
//  GLDismissableViewDelegate.h
//  GroceryList
//
//  Created by Hakon Hanesand on 3/30/15.
//
//

@import Foundation;
@import UIKit;

@class RACSignal;
@class GLDismissableView;

@protocol GLDismissableViewDelegate <NSObject>

typedef NS_ENUM(NSInteger, GLDismissableViewState) {
    GLDismissableViewStatePresented,
    GLDismissableViewStateDismissed
};

- (CGFloat)finalPositionForDismissableView:(GLDismissableView *)view inState:(GLDismissableViewState)state;
- (void)shouldDismissDismissableView:(GLDismissableView *)view withVelocity:(CGFloat)velocity;

@end
