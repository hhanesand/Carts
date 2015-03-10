//
//  GLScanningSession.m
//  GroceryList
//
//  Created by Hakon Hanesand on 3/9/15.
//
//

#import "GLScanningSession.h"
#import <AVFoundation/AVFoundation.h>
#import "GLBarcodeItem.h"
#import "ReactiveCocoa.h"

@implementation GLScanningSession

+ (GLScanningSession *)session {
    return [[GLScanningSession alloc] init];
}

- (instancetype)init {
    if (self = [super init]) {
        [self initializeCaptureSession];
        [self.captureSession startRunning];
        
        @weakify(self);
        self.barcodeSignal = [[[[[self rac_signalForSelector:@selector(captureOutput:didOutputMetadataObjects:fromConnection:) fromProtocol:@protocol(AVCaptureMetadataOutputObjectsDelegate)]
            takeUntil:self.rac_willDeallocSignal]
            reduceEach:^id(id _, NSArray *metadataObjects, id __) {
                return [metadataObjects firstObject];
            }] filter:^BOOL(AVMetadataObject *meta) {
                return [meta isKindOfClass:[AVMetadataMachineReadableCodeObject class]];
            }] map:^GLBarcodeItem *(AVMetadataMachineReadableCodeObject *barcode) {
                return [GLBarcodeItem objectWithMetadataObject:barcode];
            }];
    }
    
    return self;
}

- (void)initializeCaptureSession {
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if (!captureDevice) {
        NSLog(@"No video camera on this phone!");
        return;
    }
    
    self.captureSession = [[AVCaptureSession alloc] init];
    
    AVCaptureDeviceInput *videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:captureDevice error:nil];
    
    if ([self.captureSession canAddInput:videoInput]) {
        [self.captureSession addInput:videoInput];
    }
    
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    AVCaptureMetadataOutput *metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    if ([self.captureSession canAddOutput:metadataOutput]) {
        [self.captureSession addOutput:metadataOutput];
    }
}

@end