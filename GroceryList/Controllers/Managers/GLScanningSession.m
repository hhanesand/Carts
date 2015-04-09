//
//  GLScanningSession.m
//  GroceryList
//
//  Created by Hakon Hanesand on 3/9/15.

#import <ReactiveCocoa/ReactiveCocoa.h>

#import "GLScanningSession.h"
#import "GLBarcodeObject.h"
#import "GLBarcode.h"

@import AVFoundation;

@interface GLScanningSession()
@property (nonatomic) AVCaptureDevice *captureDevice;
@property (nonatomic) AVCaptureDeviceInput *videoInput;
@property (nonatomic) AVCaptureMetadataOutput *metadataOutput;

@property (nonatomic) AVCaptureStillImageOutput *imageCapture;
@end

@implementation GLScanningSession

+ (GLScanningSession *)session {
    return [[GLScanningSession alloc] init];
}

- (instancetype)init {
    if (self = [super init]) {
        [self initializeCaptureSession];
        [self.metadataOutput setMetadataObjectTypes:self.metadataOutput.availableMetadataObjectTypes];
    }
    
    return self;
}

- (void)pause {
    self.delegate = nil;
    
    if (self.captureSession.running) {
        [self.previewView pause];
    }
}

- (void)resumeWithDelegate:(id<GLBarcodeScannerDelegate>)delegate {
    [self startScanningWithDelegate:delegate];
    
    if (!self.captureSession.running) {
        [self.previewView resume];
    }
}

- (void)startScanningWithDelegate:(id<GLBarcodeScannerDelegate>)delegate {
    self.delegate = delegate;
    self.previewView.previewLayer.connection.enabled = YES;
    
    if (!self.captureSession.running) {
        [self.captureSession startRunning];
    }
}

- (void)initializeCaptureSession {
    if (self.captureSession) {
        return;
    }
    
    self.captureSession = [AVCaptureSession new];
    self.captureSession.sessionPreset = AVCaptureSessionPreset640x480;
    
    self.imageCapture = [AVCaptureStillImageOutput new];
    self.imageCapture.outputSettings = @{AVVideoCodecKey : AVVideoCodecJPEG, AVVideoQualityKey : @0.6};
    
    if ([self.captureSession canAddOutput:self.imageCapture]) {
        [self.captureSession addOutput:self.imageCapture];
    }
    
    self.captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if (!self.captureDevice) {
        NSLog(@"No video camera on this phone!");
        return;
    }
    
    NSError *error;
    
    self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.captureDevice error:&error];
    
    if ([self.captureSession canAddInput:self.videoInput]) {
        [self.captureSession addInput:self.videoInput];
    } else {
        NSLog(@"Error %@", error);
    }
    
    AVCaptureVideoPreviewLayer *av_previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    av_previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    self.previewView = [[GLVideoPreviewView alloc] initWithPreviewLayer:av_previewLayer];
    
    self.metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [self.metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    if ([self.captureSession canAddOutput:self.metadataOutput]) {
        [self.captureSession addOutput:self.metadataOutput];
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if ([[metadataObjects firstObject] isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
        GLBarcode *barcode = [GLBarcode barcodeWithMetadataObject:[metadataObjects firstObject]];
        [self.delegate scanner:self didRecieveBarcode:barcode];
    }
}

@end