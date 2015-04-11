//
//  GLVideoPreviewView.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/3/15.

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <POP/POP.h>

#import "GLVideoPreviewView.h"

#import "POPAnimation+GLAnimation.h"

@interface GLVideoPreviewView ()
@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UIImageView *pausedImageView;
@end

@implementation GLVideoPreviewView

- (void)resume {
    POPBasicAnimation *alpha = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
    alpha.fromValue = @(1);
    alpha.toValue = @(0);
    alpha.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    alpha.duration = 0.5;
    
    [self.pausedImageView pop_addAnimation:alpha forKey:@"fade"];
    
    [[alpha completionSignal] subscribeCompleted:^{
        [self sendSubviewToBack:self.pausedImageView];
    }];
}

- (void)pause {
    self.pausedImageView.image = [self.capturePreviewLayer screenshotInGraphicsContext];
    [self sendSubviewToBack:self.previewView];
}

- (void)setCapturePreviewLayer:(AVCaptureVideoPreviewLayer *)capturePreviewLayer {
    _capturePreviewLayer = capturePreviewLayer;
    capturePreviewLayer.frame = self.bounds;
    [self.previewView.layer addSublayer:capturePreviewLayer];
}

@end
