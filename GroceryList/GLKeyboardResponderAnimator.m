//
//  GLKeyboardResponderAnimator.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/13/15.

#import <ReactiveCocoa/ReactiveCocoa.h>

#import "GLKeyboardResponderAnimator.h"

@interface GLKeyboardResponderAnimator ()
@property (nonatomic) id<GLKeyboardMovementResponderDelegate> delegate;
@property (nonatomic) CGPoint position;
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

- (void)addNotificationCenterSignalsForKeyboard {
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil]
        takeUntil:self.rac_willDeallocSignal]
        subscribeNext:^(NSNotification *notif) {
            //see http://stackoverflow.com/a/19236013/4080860
        
            id<GLKeyboardMovementResponderDelegate> dele = self.delegate;
            
            UIView *inputView = [self.delegate viewForActiveUserInputElement];
            UIView *animatedView = [self.delegate viewToAnimateForKeyboardAdjustment];
            CGRect activeFieldFrame = inputView.frame;
            CGRect keyboardFrame = [notif.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        
            self.position = animatedView.center;
        
            if (CGRectGetMinY(keyboardFrame) - CGRectGetMaxY(activeFieldFrame) > 0) {
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:[notif.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
                [UIView setAnimationCurve:[notif.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
                [UIView setAnimationBeginsFromCurrentState:YES];
            
                CGFloat intersectionDistance = abs(CGRectGetMinY(keyboardFrame) - CGRectGetMaxY(activeFieldFrame)) + 8;
                [self.delegate viewToAnimateForKeyboardAdjustment].frame = CGRectOffset(inputView.frame, 0, -intersectionDistance);
            
                [UIView commitAnimations];
            }
    }];
    
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillHideNotification object:nil]
        takeUntil:self.rac_willDeallocSignal]
        subscribeNext:^(NSNotification *notif) {
            //see http://stackoverflow.com/a/19236013/4080860
        
            UIView *animatedView = [self.delegate viewToAnimateForKeyboardAdjustment];
        
            if (!CGPointEqualToPoint(self.position, animatedView.center)) {
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:[notif.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
                [UIView setAnimationCurve:[notif.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
                [UIView setAnimationBeginsFromCurrentState:YES];
            
                animatedView.center = self.position;
            
                [UIView commitAnimations];
            }
    }];
}

@end
