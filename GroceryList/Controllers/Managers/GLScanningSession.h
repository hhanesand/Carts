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
@interface GLScanningSession : NSObject <AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>

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

/**
 *  The layer that displays the camera on screen
 */
@property (nonatomic) AVCaptureVideoPreviewLayer *previewLayer;

/**
 *  Set this property to have the session manage the preview view
 */
@property (nonatomic) GLVideoPreviewView *previewView;

/**
 *  The capture session
 */
@property (nonatomic) AVCaptureSession *captureSession;

/**
 *  Immediately stop the video feed, but remain startable at short notice
 */
- (void)pause;

/**
 *  Resumes the video feed quickly
 *
 *  @param delegate The delegate to send barcode events to
 */
- (void)resume;

/**
 *  Set up the session for barcode scanning
 *
 *  @param delegate The delegate to send barcode events to
 */
- (void)startScanningWithDelegate:(id<GLBarcodeScannerDelegate>)delegate;

- (void)stop;

@end