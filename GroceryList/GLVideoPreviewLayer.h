//
//  GLVideoPreviewLayer.h
//  GroceryList
//
//  Created by Hakon Hanesand on 4/3/15.
//
//

@import AVFoundation;
#import <QuartzCore/QuartzCore.h>

@class RACSignal;

@interface GLVideoPreviewLayer : CALayer

@property (nonatomic) AVCaptureVideoPreviewLayer *previewLayer;

- (instancetype)initWithPreviewLayer:(AVCaptureVideoPreviewLayer *)previewLayer;

/**
 *  Pauses the video preview layer
 *
 *  @param signal A signal that will deliver a CGImage of the camera input
 */
- (void)pauseWithSignal:(RACSignal *)signal;
- (void)start;

@end
