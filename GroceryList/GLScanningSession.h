//
//  GLScanningSession.h
//  GroceryList
//
//  Created by Hakon Hanesand on 3/9/15.
//
//

@import Foundation;
#import <AVFoundation/AVFoundation.h>
#import "GLBarcodeScannerDelegate.h"

@class RACSignal;

@interface GLScanningSession : NSObject<AVCaptureMetadataOutputObjectsDelegate>

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
 *  The preview video layer that can be added to any view hierarchy
 */
@property (nonatomic) AVCaptureVideoPreviewLayer *previewLayer;

/**
 *  The capture session
 */
@property (nonatomic) AVCaptureSession *captureSession;

- (void)stopScanning;
- (void)startScanningWithDelegate:(id<GLBarcodeScannerDelegate>)delegate;

@end