//
//  CAPullToCloseTransitionManager.swift
//  Carts
//
//  Created by Hakon Hanesand on 4/26/15.
//  Copyright (c) 2015 Hakon Hanesand. All rights reserved.

import UIKit

class CAPullToCloseTransitionManager: NSObject, UIViewControllerAnimatedTransitioning, CAReversibleTransition {
    
    var presenting: Bool
    
    required override init() {
        presenting = true
        super.init()
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 1
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if self.presenting {
            self.animatePresentationWithTransitionContext(transitionContext)
        } else {
            self.animateDismissalWithTransitionContext(transitionContext)
        }
    }
    
    func animatePresentationWithTransitionContext(transitionContext: UIViewControllerContextTransitioning) {
        if let presentedControllerView = transitionContext.viewForKey(UITransitionContextToViewKey) {
            let containerView = transitionContext.containerView()
            
            presentedControllerView.center = self.translate(containerView.center, dx: 0, dy: CGRectGetHeight(presentedControllerView.frame))
            
            containerView.addSubview(presentedControllerView)
            
            let animation = POPSpringAnimation(propertyNamed: kPOPLayerPositionY)
            animation.toValue = containerView.center.y;
            animation.springSpeed = 20;
            animation.springBounciness = 0;
            
            animation.completionSignal().subscribeCompleted {
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
            }
            
            presentedControllerView.pop_addAnimation(animation, forKey: "presentPOPModal")
        }
    }
    
    func animateDismissalWithTransitionContext(transitionContext: UIViewControllerContextTransitioning) {
        if let presentedControllerView = transitionContext.viewForKey(UITransitionContextFromViewKey) {
            let containerView = transitionContext.containerView()
            
            let animation = POPSpringAnimation(propertyNamed: kPOPLayerPositionY)
            animation.toValue = self.translate(containerView.center, dx: 0, dy: CGRectGetHeight(containerView.frame)).y;
            animation.springSpeed = 20;
            animation.springBounciness = 0;
            
            animation.completionSignal().subscribeCompleted {
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
            }
            
            presentedControllerView.pop_addAnimation(animation, forKey: "dismissPOPModal")
            
        }
    }
    
    func translate(point: CGPoint, dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPointMake(point.x + dx, point.y + dy);
    }
}
