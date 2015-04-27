//
//  CAStoredAnimation.swift
//  Carts
//
//  Created by Hakon Hanesand on 4/26/15.
//  Copyright (c) 2015 Hakon Hanesand. All rights reserved.
//

import UIKit

class CAStoredAnimation: NSObject {
    var animation: POPSpringAnimation
    var identifier: NSString
    var targetObject: AnyObject
    
    required init(spring: POPSpringAnimation, description: String, targetObject: AnyObject) {
        self.animation = spring
        self.identifier = description
        self.targetObject = targetObject
        
        super.init()
    }
    
    convenience init(targetObject: AnyObject, property: String) {
        self.init(spring: CAStoredAnimation.defaultSpring(property), description: "", targetObject: targetObject)
    }
    
    class func defaultSpring(property: String) -> POPSpringAnimation {
        let spring = POPSpringAnimation(propertyNamed: property)
        spring.springSpeed = 15;
        spring.springBounciness = 15;
        return spring;
    }
    
    func startAnimation() {
        self.targetObject.pop_addAnimation(self.animation, forKey: self.description)
    }
}
