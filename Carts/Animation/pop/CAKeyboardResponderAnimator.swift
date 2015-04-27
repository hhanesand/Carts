//
//  CAKeyboardResponderAnimator.swift
//  Carts
//
//  Created by Hakon Hanesand on 4/26/15.
//  Copyright (c) 2015 Hakon Hanesand. All rights reserved.
//

import UIKit

protocol CAKeyboardMovementResponderDelegate {
    func viewForActiveUserInputElement() -> UIView
    func viewToAnimateForKeyboardAdjustment() -> UIView
    func layoutConstraintForAnimatingView() -> NSLayoutConstraint
}

class CAKeyboardResponderAnimator: NSObject {
    
    var delegate: CAKeyboardMovementResponderDelegate
    var savedConstant: CGFloat?
    
    required init(delegate: CAKeyboardMovementResponderDelegate) {
        self.delegate = delegate
        super.init()
    }
    
    func addNofificationCenterSignalsForKeyboard() {
        NSNotificationCenter.defaultCenter().rac_addObserverForName(UIKeyboardWillShowNotification, object: nil).subscribeNext { (next: AnyObject!) -> Void in
            let notif = next as! NSNotification
            let animatedView = self.delegate.viewToAnimateForKeyboardAdjustment()
            let keyboardFrame = notif.userInfo![UIKeyboardFrameEndUserInfoKey] as! CGRect
            let overlap = CGRectGetMaxX(animatedView.frame) - CGRectGetMinY(keyboardFrame)
            
            if overlap > 0 {
                let duration = notif.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
                let options = notif.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! UIViewAnimationOptions
                let constraint = self.delegate.layoutConstraintForAnimatingView()
                
                self.savedConstant = constraint.constant
                
                UIView.animateWithDuration(duration, delay: 0, options: options, animations: { () -> Void in
                    constraint.constant += overlap
                    animatedView.layoutIfNeeded()
                }, completion: nil)
            }
        }
        
        NSNotificationCenter.defaultCenter().rac_addObserverForName(UIKeyboardWillHideNotification, object: nil).subscribeNext { (next: AnyObject!) -> Void in
            let notif = next as! NSNotification
            let animatedView = self.delegate.viewToAnimateForKeyboardAdjustment()
            let constraint = self.delegate.layoutConstraintForAnimatingView()
            
            if constraint.constant != self.savedConstant! {
                let duration = notif.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
                let options = notif.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! UIViewAnimationOptions
                
                UIView.animateWithDuration(duration, delay: 0, options: options, animations: { () -> Void in
                    self.delegate.layoutConstraintForAnimatingView().constant = self.savedConstant!
                    animatedView.layoutIfNeeded()
                }, completion: nil)
            }
        }
    }
}
