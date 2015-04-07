//
//  GLVideoPreviewLayer.h
//  GroceryList
//
//  Created by Hakon Hanesand on 4/3/15.

@import AVFoundation;
@import UIKit;

@class RACSignal;

@interface GLVideoPreviewView : UIView

@property (nonatomic) AVCaptureVideoPreviewLayer *previewLayer;

- (instancetype)initWithPreviewLayer:(AVCaptureVideoPreviewLayer *)previewLayer;

/**
 *  Pauses the video preview layer
 *
 *  @param image An image of the camera stream
 */
- (void)pauseWithImage:(UIImage *)image;
- (void)resume;

@end
