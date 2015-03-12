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
@end

@implementation GLScanningSession

+ (GLScanningSession *)session {
    return [[GLScanningSession alloc] init];
}

- (instancetype)init {
    if (self = [super init]) {
        [self initializeCaptureSession];
        [self.captureSession startRunning];
        [self.metadataOutput setMetadataObjectTypes:self.metadataOutput.availableMetadataObjectTypes];
        
//        @weakify(self);
//        [[[[[[[self rac_signalForSelector:@selector(captureOutput:didOutputMetadataObjects:fromConnection:) fromProtocol:@protocol(AVCaptureMetadataOutputObjectsDelegate)] logAll]
//        takeUntil:self.rac_willDeallocSignal]
//        reduceEach:^id(id _, NSArray *metadataObjects, id __) {
//            return [metadataObjects firstObject];
//        }] filter:^BOOL(AVMetadataObject *meta) {
//            return [meta isKindOfClass:[AVMetadataMachineReadableCodeObject class]];
//        }] map:^GLBarcodeItem *(AVMetadataMachineReadableCodeObject *barcode) {
//                return [GLBarcodeItem objectWithMetadataObject:barcode];
//        }] doNext:^(id x) {
//            @strongify(self);
//            [self.delegate scanner:self didRecieveBarcodeItem:x];
//        }];
    }
    
    return self;
}

- (void)stopScanning {
    [self.captureSession stopRunning];
}

- (void)initializeCaptureSession {
    if (self.captureSession) {
        return;
    }
    
    self.captureSession = [[AVCaptureSession alloc] init];
    
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
    
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
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