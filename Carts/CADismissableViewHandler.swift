//
//  CADismissableViewHandler.swift
//  Carts
//
//  Created by Hakon Hanesand on 4/26/15.
//  Copyright (c) 2015 Hakon Hanesand. All rights reserved.

import UIKit

@objc protocol CADismissableHandlerDelegate {
    optional func didPresentViewAfterUserInteraction()
    optional func didDismissViewAfterUserInteraction()
    optional func willPresentViewAfterUserInteraction()
    optional func willDismissViewAfterUserInteraction()
}

class CADismissableViewHandler: NSObject, UIGestureRecognizerDelegate {
   
    weak var constraint: NSLayoutConstraint?
    var superviewHeight: CGFloat
    var animateableView: UIView
    var dismissedPosition: CGFloat
    var enabled: Bool
    var delegate: CADismissableHandlerDelegate?
    
    var height: CGFloat {
        return CGRectGetHeight(self.animateableView.frame)
    }
    
    var presentedPosition: CGFloat {
        return self.superviewHeight - (self.dismissedPosition + CGRectGetHeight(self.animateableView.frame))
    }
    
    required init(animateableView: UIView, superviewHeight: CGFloat, animateableConstraint: NSLayoutConstraint) {
        self.constraint = animateableConstraint
        self.superviewHeight = superviewHeight
        self.animateableView = animateableView
        self.dismissedPosition = animateableConstraint.constant
        self.enabled = false
        
        super.init()
    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return self.enabled
    }
    
    func handlePan(pan: UIPanGestureRecognizer) {
        if pan.state == .Began {
            self.userDidStartInteractionWithGestureRecognizer(pan);
        } else if pan.state == .Changed {
            self.userDidPanDismissableViewWithGestureRecognizer(pan);
        } else if pan.state == .Ended {
            self.userDidEndInteractionWithGestureRecognizer(pan);
        }
    }
    
    func userDidStartInteractionWithGestureRecognizer(pan: UIPanGestureRecognizer) {
        self.constraint?.pop_removeAllAnimations()
    }
    
    func userDidPanDismissableViewWithGestureRecognizer(pan: UIPanGestureRecognizer) {
        let locationOfFinger = pan.locationInView(pan.view)
    
        if locationOfFinger.y >= self.presentedPosition {
            self.constraint?.constant = locationOfFinger.y - self.superviewHeight;
        }
    }
    
    func userDidEndInteractionWithGestureRecognizer(pan: UIPanGestureRecognizer) {
        let distancePastPresentedPosition = pan.locationInView(pan.view).y - self.presentedPosition
        let velocity = pan.velocityInView(pan.view).y
        let velocityFactor = velocity / 30
        
        if distancePastPresentedPosition + velocityFactor >= self.height / 2 {
            self.delegate?.willDismissViewAfterUserInteraction?()
            
            self.dismissViewWithVelocity(velocity).subscribeCompleted {
                self.delegate?.didDismissViewAfterUserInteraction?()
            }
        } else {
            self.delegate?.willPresentViewAfterUserInteraction?()
            
            self.presentViewWithVelocity(velocity).subscribeCompleted {
                self.delegate?.didPresentViewAfterUserInteraction?()
            }
        }
    }
    
    func dismissViewWithVelocity(velocity: CGFloat) -> RACSignal {
        let down = POPSpringAnimation(propertyNamed: kPOPLayoutConstraintConstant)
        down.toValue = self.dismissedPosition
        down.springBounciness = 0;
        down.springSpeed = 20;
        down.velocity = velocity;
        down.name = "DismissInteractiveView";
        
        self.constraint?.pop_addAnimation(down, forKey: "dismiss_interactive_view")
        
        return down.completionSignal()
    }
    
    func presentViewWithVelocity(velocity: CGFloat) -> RACSignal {
        let up = POPSpringAnimation(propertyNamed: kPOPLayoutConstraintConstant)
        up.toValue = self.presentedPosition - self.superviewHeight;
        up.springSpeed = 20;
        up.springBounciness = abs(velocity) / 400;
        up.velocity = velocity;
        up.name = "PresentInteractiveView";
        
        self.constraint?.pop_addAnimation(up, forKey: "present_interactive_view")
        
        return up.completionSignal()
    }
}
