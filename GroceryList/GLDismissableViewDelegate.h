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

//datasource for final postition - usually the bottom of the screen
- (CGFloat)finalPositionForDismissableView:(GLDismissableView *)view inState:(GLDismissableViewState)state;
- (void)shouldDismissDismissableView:(GLDismissableView *)view withGestureRecognizer:(UIPanGestureRecognizer *)pan;

@end
