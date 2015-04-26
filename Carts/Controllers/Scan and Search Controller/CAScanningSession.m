//
//  CAScanningSession.m
//  GroceryList
//
//  Created by Hakon Hanesand on 3/9/15.

#import <ReactiveCocoa/ReactiveCocoa.h>

#import "CAScanningSession.h"
#import "CABarcodeObject.h"
#import "CABarcode.h"
#import "UIImage+CAImage.h"

@import AVFoundation;

@interface CAScanningSession()
@property (nonatomic) AVCaptureDevice *captureDevice;
@property (nonatomic) AVCaptureDeviceInput *videoInput;
@property (nonatomic) AVCaptureMetadataOutput *metadataOutput;
@property (nonatomic) AVCaptureVideoDataOutput *videoOutput;

@property (nonatomic) AVCaptureStillImageOutput *imageCapture;

@property (nonatomic) AVCaptureConnection *connection;
@property (nonatomic) BOOL paused;

@property (nonatomic) UIImage *recievedImage;
@end

@implementation CAScanningSession

+ (CAScanningSession *)session {
    return [[CAScanningSession alloc] init];
}

- (instancetype)init {
    if (self = [super init]) {
        [self initializeCaptureSession];
        [self setupCaptureSignal];
        [self.metadataOutput setMetadataObjectTypes:self.metadataOutput.availableMetadataObjectTypes];
    }
    
    return self;
}

- (void)setupCaptureSignal {
    //captures barcodes from the camera and maps them to CABarcodes
    
    RACSignal *barcodeSelectorSignal = [self rac_signalForSelector:@selector(captureOutput:didOutputMetadataObjects:fromConnection:) fromProtocol:@protocol(AVCaptureMetadataOutputObjectsDelegate)];
    
    self.barcodeSignal = [[[[[barcodeSelectorSignal filter:^BOOL(RACTuple *value) {
        return !self.paused && [[value.second firstObject] isKindOfClass:[AVMetadataMachineReadableCodeObject class]]; //optimization
    }] bufferWithTime:0.5 onScheduler:[RACScheduler scheduler]] map:^CABarcode *(RACTuple *buffer) {
        RACTuple *firstSelectorTuple = buffer.first;
        NSArray *barcodeMetadataObjects = firstSelectorTuple.second;
        return [CABarcode barcodeWithMetadataObject:[barcodeMetadataObjects firstObject]];
    }] logNext] filter:^BOOL(id value) {
        return !self.paused; //double check that we are not paused
    }];
}

- (void)pause {
    self.paused = YES;
}

- (void)resume {
    self.paused = NO;
}

- (void)start {
    if (!self.captureSession.running) {
        dispatch_async(dispatch_get_CAobal_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [self.captureSession startRunning];
        });
    }
    
}

- (void)stop {
    if (self.captureSession.running) {
        dispatch_async(dispatch_get_CAobal_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [self.captureSession stopRunning];
        });
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
}

- (RACSignal *)captureImageFromVideoOutput {
    self.connection.enabled = YES; //start the output of frames and after recieving one
    
    //observe the recievedImage property for changes
    return [[RACObserve(self, recievedImage) skip:1] take:1];
}

//saves the connection to a property (so it can be resumed later), then disables the connection
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    self.connection = connection;
    connection.enabled = NO;
    
    //set the recieved image property so observers can fire signals
    self.recievedImage = [UIImage imageFromSampleBuffer:sampleBuffer];
}

@end