//
//  CACameraLayer.swift
//  Carts
//
//  Created by Hakon Hanesand on 4/26/15.
//  Copyright (c) 2015 Hakon Hanesand. All rights reserved.
//

import UIKit

class CACameraLayer: CAShapeLayer {
    
    var lineLength: CGFloat
    var reticuleCornerRadius: CGFloat
    
    required init(bounds: CGRect, cornerRadius: CGFloat, lineLength: CGFloat) {
        self.lineLength = lineLength
        self.reticuleCornerRadius = cornerRadius
        
        super.init()
        
        self.configure(bounds)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(bounds: CGRect) {
        self.lineLength = 2
        self.fillColor = UIColor.clearColor().CGColor!
        self.strokeColor = UIColor.whiteColor().CGColor!
        self.lineCap = kCALineJoinRound
        self.opacity = 0.3
        
        self.path = self.buildPath(bounds).CGPath
    }
    
    func buildPath(bounds: CGRect) -> UIBezierPath {
        return UIBezierPath(roundedRect: bounds, cornerRadius: self.reticuleCornerRadius)
    }
}
