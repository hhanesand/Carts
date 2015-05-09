//
//  VideoPreviewView.swift
//  Carts
//
//  Created by Hakon Hanesand on 5/9/15.
//  Copyright (c) 2015 Hakon Hanesand. All rights reserved.
//

import UIKit

class VideoPreviewView: UIView {
    
//    @property (weak, nonatomic) IBOutlet UIView *previewView;
//    @property (weak, nonatomic) IBOutlet UIImageView *pausedImageView;
//    @property (weak, nonatomic) IBOutlet UIButton *doneScanningItemsButton;

    var capturePreviewLayer: AVCaptureVideoPreviewLayer? {
        didSet {
            capturePreviewLayer?.frame = bounds
//            previewView.addSublayer(capturePreviewLayer)
        }
    }
    
    override var frame: CGRect {
        didSet {
            self.capturePreviewLayer?.frame = bounds
        }
    }

    func pauseWithImage(image: UIImage) {
        dispatch_async(dispatch_get_main_queue()) {
            //self.pausedImageView.alpha = 1;
            //self.pausedImageView.image = [image copy];
            //[self.pausedImageView setNeedsDisplay];
        }
    }
    
    func resume() {
        //self.pausedImageView.alpha = 1;

        //POPBasicAnimation *alpha = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
        //alpha.toValue = @(0);
        //alpha.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        //alpha.duration = 0.2;
        
        //[self.pausedImageView pop_addAnimation:alpha forKey:@"fade"];
    }
}
