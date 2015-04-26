//
//  CAVideoPreviewView.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/3/15.

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <POP/POP.h>

#import "CAVideoPreviewView.h"

#import "POPAnimation+CAAnimation.h"

@interface CAVideoPreviewView ()

@end

@implementation CAVideoPreviewView

- (void)resume {
//    self.pausedImageView.alpha = 1;
//    
//    POPBasicAnimation *alpha = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
//    alpha.toValue = @(0);
//    alpha.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    alpha.duration = 0.2;
    
//    [self.pausedImageView pop_addAnimation:alpha forKey:@"fade"];
}

- (void)pauseWithImage:(UIImage *)image {
//    NSLog(@"Pausing image");
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        self.pausedImageView.alpha = 1;
//        self.pausedImageView.image = [image copy];
//        [self.pausedImageView setNeedsDisplay];
//    });
}

- (void)setCapturePreviewLayer:(AVCaptureVideoPreviewLayer *)capturePreviewLayer {
    _capturePreviewLayer = capturePreviewLayer;
    NSLog(@"Bounds %@", NSStringFromCGRect(self.bounds));
    capturePreviewLayer.frame = self.bounds;
    [self.previewView.layer addSublayer:capturePreviewLayer];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.capturePreviewLayer.frame = self.bounds;
}

@end
