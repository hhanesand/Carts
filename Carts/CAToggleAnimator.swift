//
//  CAToggleAnimator.swift
//  Carts
//
//  Created by Hakon Hanesand on 4/26/15.
//  Copyright (c) 2015 Hakon Hanesand. All rights reserved.
//

import UIKit

class CAToggleAnimator: NSObject, CACompanionAnimator {
 
    var backwards: CAStoredAnimation
    var forwards: CAStoredAnimation
    
    var forwardsAction: (() -> ())?
    var backwardsAction: (() -> ())?
    
    var nextAnimationForwards: Bool
    
    required init(target: AnyObject, property: String, start: AnyObject, end: AnyObject) {
        self.backwards = CAStoredAnimation(targetObject: target, property: property)
        self.forwards = CAStoredAnimation(targetObject: target, property: property)
        
        self.backwards.animation.fromValue = end
        self.backwards.animation.toValue = start
        
        self.forwards.animation.fromValue = start
        self.forwards.animation.toValue = end
        
        self.nextAnimationForwards = true
        
        super.init()
    }
    
    func toggleAnimation() {
        if self.nextAnimationForwards {
            self.forwardsAction?()
            self.forwards.startAnimation()
        } else {
            self.backwardsAction?()
            self.backwards.startAnimation()
        }
        
        self.nextAnimationForwards = !self.nextAnimationForwards
    }
}
