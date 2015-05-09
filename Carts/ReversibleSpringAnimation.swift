//
//  ReversiblePOPSpringAnimation.swift
//  Carts
//
//  Created by Hakon Hanesand on 5/9/15.
//  Copyright (c) 2015 Hakon Hanesand. All rights reserved.

extension POPSpringAnimation {
    
    func reverse() -> POPSpringAnimation {
        let reversed = POPSpringAnimation(propertyNamed: property.name)
        reversed.springBounciness = springBounciness
        reversed.springSpeed = springSpeed
        
        reversed.toValue = fromValue
        reversed.fromValue = toValue
        
        reversed.name = "reversed_\(name)"
        
        return reversed
    }
}