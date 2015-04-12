//
//  GLScanningSession.m
//  GroceryList
//
//  Created by Hakon Hanesand on 3/9/15.

#import <ReactiveCocoa/ReactiveCocoa.h>

#import "GLScanningSession.h"
#import "GLBarcodeObject.h"
#import "GLBarcode.h"
#import "UIImage+GLImage.h"

@import AVFoundation;

@interface GLScanningSession()
@property (nonatomic) AVCaptureDevice *captureDevice;
@property (nonatomic) AVCaptureDeviceInput *videoInput;
@property (nonatomic) AVCaptureMetadataOutput *metadataOutput;
@property (nonatomic) AVCaptureVideoDataOutput *videoOutput;

@property (nonatomic) AVCaptureStillImageOutput *imageCapture;

@property (nonatomic) AVCaptureConnection *connection;
@property (nonatomic) BOOL paused;

@property (nonatomic) UIImage *recievedImage;
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
    if (!self.paused) {
        self.paused = YES;
        //self.previewLayer.connection.enabled = NO;
        
//        [[self captureImageFromVideoOutput] subscribeNext:^(id volatil) {
//            NSLog(@"Setting image");
//            [self.previewView pauseWithImage:volatil];
//        }];
    }
}

- (void)resume {
    if (self.paused) {
        self.paused = NO;
        //self.previewLayer.connection.enabled = YES;
        [self.previewView resume];
    }
}

- (void)startScanningWithDelegate:(id<GLBarcodeScannerDelegate>)delegate {
    if (!self.captureSession.running) {
        self.delegate = delegate;
        [self.captureSession startRunning];
    }
}

- (void)stop {
    if (self.captureSession.running) {
        self.delegate = nil;
        [self.captureSession stopRunning];
    }
}

- (void)initializeCaptureSession {
    if (self.captureSession) {
        return;
    }
    
    self.captureSession = [AVCaptureSession new];
    self.captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    
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
    
    AVCaptureVideoDataOutput *videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    
    if ([self.captureSession canAddOutput:videoOutput]) {
        [self.captureSession addOutput:videoOutput];
    }
    
    videoOutput.videoSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
    [videoOutput setSampleBufferDelegate:self queue:dispatch_queue_create("dispatch", 0)];
    
    self.metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [self.metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    if ([self.captureSession canAddOutput:self.metadataOutput]) {
        [self.captureSession addOutput:self.metadataOutput];
    }
    
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
}

- (RACSignal *)captureImageFromVideoOutput {
    NSLog(@"Requesting image");
    self.connection.enabled = YES; //start the output of frames and after recieving one
    
    //observe the recievedImage property for changes
    return [[RACObserve(self, recievedImage) skip:1] take:1];
}

//saves the connection to a property (so it can be resumed later), then disables the connection
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    NSLog(@"Recieved frame");
    self.connection = connection;
    connection.enabled = NO;
    
    //set the recieved image property so observers can fire signals
    self.recievedImage = [UIImage imageFromSampleBuffer:sampleBuffer];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (!self.paused && [[metadataObjects firstObject] isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
        GLBarcode *barcode = [GLBarcode barcodeWithMetadataObject:[metadataObjects firstObject]];
        [self.delegate scanner:self didRecieveBarcode:barcode];
    }
}

@end