//
//  GLScanningSession.h
//  GroceryList
//
//  Created by Hakon Hanesand on 3/9/15.

#import "GLBarcodeScannerDelegate.h"
#import "GLVideoPreviewView.h"

@import Foundation;
@import AVFoundation;

@class RACSignal;

/**
 *  Stores a scanning session that encapsulates all AVFoundation objects
 */
@interface GLScanningSession : NSObject <AVCaptureMetadataOutputObjectsDelegate>

/**
 *  Sets up a new scanning session
 *
 *  @return An object encapsulting the scanning session
 */
+ (GLScanningSession *)session;

/**
 *  The object that responds to scanning events
 */
@property (nonatomic) id<GLBarcodeScannerDelegate> delegate;

@property (nonatomic) GLVideoPreviewView *previewView;

/**
 *  The capture session
 */
@property (nonatomic) AVCaptureSession *captureSession;

- (void)pause;
- (void)resumeWithDelegate:(id<GLBarcodeScannerDelegate>)delegate;

- (void)startScanningWithDelegate:(id<GLBarcodeScannerDelegate>)delegate;


/**
 *  Captures an image from the camera
 *
 *  @return A signal that will return the CGImage from the camera
 */
- (RACSignal *)captureImageFromCamera;

@end