//
//  CAPullToCloseTransitionPresentationController.swift
//  Carts
//
//  Created by Hakon Hanesand on 4/26/15.
//  Copyright (c) 2015 Hakon Hanesand. All rights reserved.
//

import UIKit

class CAPullToCloseTransitionPresentationController: UIPresentationController {

    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        self.containerView!.addSubview(self.presentedView()!)
    }
    
    override func presentationTransitionDidEnd(completed: Bool) {
        super.presentationTransitionDidEnd(completed)
    }
    
    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
    }
    
    override func dismissalTransitionDidEnd(completed: Bool) {
        super.dismissalTransitionDidEnd(completed)
    }
    
    override func frameOfPresentedViewInContainerView() -> CGRect {
        return self.containerView!.bounds
    }
}
