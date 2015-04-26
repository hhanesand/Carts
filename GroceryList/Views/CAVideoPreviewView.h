//
//  GLVideoPreviewLayer.h
//  GroceryList
//
//  Created by Hakon Hanesand on 4/3/15.

@import AVFoundation;
@import UIKit;

@class RACSignal;

/**
 *  A view that manages a AVCaptureVideoPreviewLayer and smoothly (and quickly) fades between the paused and started phase
 */
@interface GLVideoPreviewView : UIView

@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UIImageView *pausedImageView;
@property (weak, nonatomic) IBOutlet UIButton *doneScanningItemsButton;

@property (nonatomic) AVCaptureVideoPreviewLayer *capturePreviewLayer;

/**
 *  Pauses the video preview layer and displays an image until the camera is started again
 */
- (void)pauseWithImage:(UIImage *)image;

/**
 *  Resumes the video preview layer, quickly fading from the image that was saved in pause to the current camera feed to transition smoothly
 */
- (void)resume;

@end
