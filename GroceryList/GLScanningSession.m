//
//  GLScanningSession.m
//  GroceryList
//
//  Created by Hakon Hanesand on 3/9/15.
//
//

#import "GLScanningSession.h"
#import <AVFoundation/AVFoundation.h>
#import "GLBarcodeObject.h"
#import "ReactiveCocoa.h"
#import "GLBarcode.h"

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
        [self.previewLayer pauseWithSignal:[self captureImageFromCamera]];
    }
}

- (void)resumeWithDelegate:(id<GLBarcodeScannerDelegate>)delegate {
    [self.previewLayer resume];
    
    [self startScanningWithDelegate:delegate];
}

- (void)startScanningWithDelegate:(id<GLBarcodeScannerDelegate>)delegate {
    self.delegate = delegate;
    self.previewLayer.previewLayer.connection.enabled = YES;
    
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
    
    self.previewLayer = [[GLVideoPreviewLayer alloc] initWithPreviewLayer:av_previewLayer];
    
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

- (RACSignal *)captureImageFromCamera {
    AVCaptureConnection *captureConnection = [self.imageCapture connectionWithMediaType:AVMediaTypeVideo];
    
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self.imageCapture captureStillImageAsynchronouslyFromConnection:captureConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage *image = [UIImage imageWithData:imageData];
            [subscriber sendNext:(id)image.CGImage];
            [subscriber sendCompleted];
        }];
        
        return nil;
    }] subscribeOn:[RACScheduler schedulerWithPriority:RACSchedulerPriorityHigh]];
}

@end