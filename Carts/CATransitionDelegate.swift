//
//  CATransitionDelegate.swift
//  Carts
//
//  Created by Hakon Hanesand on 4/26/15.
//  Copyright (c) 2015 Hakon Hanesand. All rights reserved.
//

import UIKit

class CATransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    var controller: UIViewController
    var animator: CAPullToCloseTransitionManager
   
    required init(controller: UIViewController) {
        self.controller = controller
        self.animator = CAPullToCloseTransitionManager()
        
        super.init()
    }
    
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController!, sourceViewController source: UIViewController) -> UIPresentationController? {
        return CAPullToCloseTransitionPresentationController(presentedViewController: presented, presentingViewController: presenting)
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.animator.presenting = true
        return self.animator
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.animator.presenting = false
        return self.animator
    }
}
