//
//  CAScanningSession.h
//  GroceryList
//
//  Created by Hakon Hanesand on 3/9/15.

#import "CAVideoPreviewView.h"
#import "CACameraLayer.h"

@import Foundation;
@import AVFoundation;

@class RACSignal;

/**
 *  Stores a scanning session that encapsulates all AVFoundation objects
 */
@interface CAScanningSession : NSObject <AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>

/**
 *  Sets up a new scanning session
 *
 *  @return An object encapsulting the scanning session
 */
+ (CAScanningSession *)session;

@property (nonatomic) RACSignal *barcodeSignal;

/**
 *  The capture session
 */
@property (nonatomic) AVCaptureSession *captureSession;

/**
 *  Immediately stop the video feed, but remain startable at short notice
 */
- (void)pause;

/**
 *  Asynchronously resumes the video feed
 *
 *  @param delegate The delegate to send barcode events to
 */
- (void)resume;

/**
 *  Set up the session for barcode scanning
 *
 *  @param delegate The delegate to send barcode events to
 */
- (void)start;

/**
 *  Stops the scanning of barcodes
 */
- (void)stop;

@end