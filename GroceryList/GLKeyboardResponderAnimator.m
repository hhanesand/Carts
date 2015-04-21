//
//  GLKeyboardResponderAnimator.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/13/15.

#import <ReactiveCocoa/ReactiveCocoa.h>

#import "GLKeyboardResponderAnimator.h"

@interface GLKeyboardResponderAnimator ()
@property (nonatomic) id<GLKeyboardMovementResponderDelegate> delegate;
@property (nonatomic) CGFloat savedConstant;
@end

@implementation GLKeyboardResponderAnimator

- (instancetype)initWithDelegate:(id<GLKeyboardMovementResponderDelegate>)delegate
{
    if (self = [super init]) {
        self.delegate = delegate;
        [self addNotificationCenterSignalsForKeyboard];
    }
    
    return self;
}

//see http://stackoverflow.com/a/19236013/4080860
- (void)addNotificationCenterSignalsForKeyboard {
    @weakify(self);
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification *notif) {
        @strongify(self);
        
        UIView *inputView = [self.delegate viewForActiveUserInputElement];
        UIView *animatedView = [self.delegate viewToAnimateForKeyboardAdjustment];
        
        CGRect activeFieldFrame = inputView.frame;
        CGRect keyboardFrame = [notif.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        
        CGFloat overlap = CGRectGetMaxY(activeFieldFrame) - CGRectGetMinY(keyboardFrame);
        
        if (overlap > 0) {
            NSTimeInterval duration = [notif.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
            CGFloat options = [notif.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
            NSLayoutConstraint *constraint = [self.delegate layoutConstraintForAnimatingView];
            
            self.savedConstant = constraint.constant;
            
            [UIView animateWithDuration:duration delay:0 options:options animations:^{
                constraint.constant = overlap;
                [animatedView layoutIfNeeded];
            } completion:nil];
        }
    }];
    
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillHideNotification object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification *notif) {
        UIView *animatedView = [self.delegate viewToAnimateForKeyboardAdjustment];
        NSLayoutConstraint *constraint = [self.delegate layoutConstraintForAnimatingView];
        
        if (!constraint.constant == self.savedConstant) {
            NSTimeInterval duration = [notif.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
            CGFloat options = [notif.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
            
            [UIView animateWithDuration:duration delay:0 options:options animations:^{
                [self.delegate layoutConstraintForAnimatingView].constant = self.savedConstant;
                [animatedView layoutIfNeeded];
            } completion:nil];
        }
    }];
}

@end
