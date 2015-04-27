//
//  CAAuthenticationButton.swift
//  Carts
//
//  Created by Hakon Hanesand on 4/26/15.
//  Copyright (c) 2015 Hakon Hanesand. All rights reserved.
//

import UIKit

class CAAuthenticationButton: UIButton {
    @IBOutlet weak var activityIndicator: MRActivityIndicatorView! {
        didSet {
            if self.shouldAnimate! {
                self.fade = CAToggleAnimator(target: self.activityIndicator.layer, property: kPOPLayerOpacity, start: 0, end: 1)
                
                self.fade?.forwardsAction = {
                    self.setTitle(nil, forState: .Normal)
                    self.setImage(nil, forState: .Normal)
                    self.activityIndicator.startAnimating()
                }
                
                self.fade?.backwardsAction = {
                    self.setTitle(self.savedTitle, forState: .Normal)
                    self.setImage(self.savedImage, forState: .Normal)
                    self.activityIndicator.startAnimating()
                }
            }
        }
    }
    
    @IBInspectable var shouldAnimate: Bool?
    
    var shake: CAStoredAnimation?
    var fade: CAToggleAnimator?
    
    var savedTitle: String?
    var savedImage: UIImage?
    
    var image: UIImage

    required init(coder aDecoder: NSCoder) {
        self.image = UIImage(named: "done")!
        super.init(coder: aDecoder)
    }
    
    func animateError() {
        let posx = POPSpringAnimation(propertyNamed: kPOPLayerPositionX)
        posx.velocity = 2000;
        posx.springBounciness = 20;
        posx.springSpeed = 20;
        
        let posx2 = POPSpringAnimation(propertyNamed: kPOPLayerPositionX)
        posx2.velocity = 2000;
        posx2.springBounciness = 20;
        posx2.springSpeed = 20;
        
        self.activityIndicator.layer.pop_addAnimation(posx, forKey: "ani")
        self.layer.pop_addAnimation(posx2, forKey: "ani2")
        
        self.fade?.toggleAnimation()
    }
    
    func animateSuccess() {
        self.activityIndicator.startAnimating()
        self.setTitle(nil, forState: .Normal)
        self.setImage(self.image, forState: .Normal)
    }
}
