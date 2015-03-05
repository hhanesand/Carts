//
//  GLScannerWrapperViewController.m
//  GroceryList
//
//  Created by Hakon Hanesand on 2/25/15.
//
//

#import "GLScannerWrapperViewController.h"
#import "GLBarcodeItem.h"

@interface GLScannerWrapperViewController ()
@property (nonatomic) AVCaptureSession *captureSession;
@property (nonatomic) AVCaptureDevice *captureDevice;
@property (nonatomic) AVCaptureDeviceInput *videoInput;
@property (nonatomic) AVCaptureMetadataOutput *metadataOutput;
@property (nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic) BOOL running;

@property (nonatomic) UIView *previewView;
@end

#define TICK NSDate *startTime = [NSDate date]
#define TOCK NSLog(@"Time: %f", -[startTime timeIntervalSinceNow])

@implementation GLScannerWrapperViewController

- (instancetype)init {
    if (self = [super init]) {
        [self setupCaptureSession];
        [self setupViews];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
        [self startScanning];
    }
    
    return self;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self stopScanning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self startScanning];
}

- (void)setupViews {
    NSLog(@"Rect in wrapper %@", NSStringFromCGRect(self.view.frame));
    self.previewLayer.frame = self.view.frame;
    [self.view.layer addSublayer:self.previewLayer];
}

- (void)setupCaptureSession {
    if (self.captureSession) {
        return;
    }
    
    self.captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if (!self.captureDevice) {
        NSLog(@"No video camera on this phone!");
        return;
    }
    
    self.captureSession = [[AVCaptureSession alloc] init];
    
    self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.captureDevice error:nil];
    
    if ([self.captureSession canAddInput:self.videoInput]) {
        [self.captureSession addInput:self.videoInput];
    }
    
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    self.metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [self.metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    if ([self.captureSession canAddOutput:self.metadataOutput]) {
        [self.captureSession addOutput:self.metadataOutput];
    }
}

- (void)stopScanning {
    if (!self.running) {
        return;
    }
    
    [self.captureSession stopRunning];
    self.running = NO;
}

- (void)startScanning {
    if (self.running) {
        return;
    }
    
    [self.captureSession startRunning];
    [self.metadataOutput setMetadataObjectTypes:self.metadataOutput.availableMetadataObjectTypes];
    self.running = YES;
}

- (void)applicationWillEnterForeground:(NSNotification *)notif {
    [self startScanning];
}

- (void)applicationWillEnterBackground:(NSNotification *)notif {
    [self stopScanning];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    NSMutableArray *results = [NSMutableArray new];
    
    for (AVMetadataObject *barcode in metadataObjects) {
        if ([barcode isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
            [results addObject:[GLBarcodeItem objectWithMetadataObject:(AVMetadataMachineReadableCodeObject *)barcode]];
        }
    }
    
    [self.delegate scanner:self didRecieveBarcodeItems:results];
}

@end
