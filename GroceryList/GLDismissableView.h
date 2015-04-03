//
//  GLDismissableView.h
//  GroceryList
//
//  Created by Hakon Hanesand on 3/30/15.
//
//

@import Foundation;
@import UIKit;

@class RACSignal;

#import "GLDismissableViewDelegate.h"

@interface GLDismissableView : UIView <UIGestureRecognizerDelegate>

- (RACSignal *)presentView;
- (RACSignal *)dismissViewWithVelocity:(CGFloat)velocity;

@property (nonatomic) id<GLDismissableViewDelegate> delegate;
@property (nonatomic) CGFloat permissableDeltaForPanGesture;
@property (nonatomic) CGPoint initalPosition;

@end
