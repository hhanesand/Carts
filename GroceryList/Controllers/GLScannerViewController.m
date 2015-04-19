//
//  GLScannerViewController.m
//  GroceryList
//
//  Created by Hakon Hanesand on 2/11/15.

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <Pop/POP.h>
#import <SVProgressHUD/SVProgressHUD.h>

#import "GLScannerViewController.h"
#import "GLManualEntryView.h"
#import "GLScanningSession.h"
#import "GLBarcode.h"
#import "GLCameraLayer.h"
#import "GLBarcodeFetchManager.h"
#import "GLPullToCloseTransitionManager.h"
#import "GLPullToCloseTransitionPresentationController.h"

#import "POPAnimation+GLAnimation.h"
#import "JVFloatLabeledTextField.h"
#import "GLTransitionDelegate.h"
#import "GLKeyboardResponderAnimator.h"
#import "GLBarcodeObject.h"
#import "GLProgressHUD.h"
#import "GLListObject.h"

static CGFloat const kGLManualEntryViewPositionRatio = 0.6f;

typedef RACSignal* (^RACCommandBlock)(id);

@interface GLScannerViewController()
@property (nonatomic, copy) RACCommandBlock doneScanningBlock;

@property (nonatomic) GLTransitionDelegate *transitionDelegate;
@property (nonatomic) GLDismissableViewHandler *manualEntryViewDismissHandler;

@property (nonatomic) GLKeyboardResponderAnimator *responder;

@property (nonatomic) GLBarcodeFetchManager *barcodeManager;
@property (nonatomic) GLScanningSession *barcodeScanner;

@property (strong, nonatomic) IBOutlet GLVideoPreviewView *videoPreviewView;
@property (nonatomic) GLCameraLayer *targetingReticule;
@property (nonatomic) GLManualEntryView *manualEntryView;
@end

static NSString *identifier = @"GLBarcodeItemTableViewCell";

@implementation GLScannerViewController

#pragma mark - Setup

- (instancetype)init {
    if (self = [super initWithNibName:NSStringFromClass([GLScannerViewController class]) bundle:[NSBundle mainBundle]]) {
        [self configureModalPresentation];
        [self.barcodeScanner start];
    }
    
    return self;
}

- (void)configureModalPresentation {
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.transitioningDelegate = self.transitionDelegate;
    self.modalPresentationCapturesStatusBarAppearance = YES;
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initializeKeyboardAnimations];
    [self initializeRACCommandBlocks];
    [self initializeVideoPreviewLayer];
    [self subscribeToBarcodeScannerOutput];
}

- (void)initializeKeyboardAnimations {
    self.responder = [[GLKeyboardResponderAnimator alloc] initWithDelegate:self];
}

- (void)initializeRACCommandBlocks {
    @weakify(self);
    self.doneScanningBlock = ^RACSignal *(id input) {
        @strongify(self);
        [self.barcodeScanner resume];
        return [self.animationStack popAllAnimations];
    };
}

- (void)initializeVideoPreviewLayer {
    [self.barcodeScanner start];
    [self.view insertSubview:self.videoPreviewView atIndex:0];
}

- (void)subscribeToBarcodeScannerOutput {
    self.listItemSignal = [[[[self.barcodeScanner.barcodeSignal doNext:^(id x) {
        [GLProgressHUD show];
        [self.barcodeScanner pause];
    }] flattenMap:^RACStream *(GLBarcode *barcode) {
        return [[self.barcodeManager fetchProductInformationForBarcode:barcode] catch:^RACSignal *(NSError *error) {
            [self displayManualEntryView];
            
            RACSignal *confirm = [[self.manualEntryView.confirm rac_signalForControlEvents:UIControlEventTouchUpInside] map:^id(id _) {
                return [GLBarcodeObject objectWithName:self.manualEntryView.name.text];
            }];
            
            RACSignal *cancel = [[self.manualEntryView.cancel rac_signalForControlEvents:UIControlEventTouchUpInside] map:^id(id value) {
                return nil;
            }];
            
            return [[[[RACSignal merge:@[confirm, cancel]] take:1] doNext:^(id x) {
                [self dismissManualEntryView];
            }] filter:^BOOL(id value) {
                return value;
            }];
        }];
    }] doNext:^(GLBarcodeObject *barcodeObject) {
        [GLProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"Added %@", barcodeObject.name]];
        [self.barcodeScanner resume];
    }] logAll];
}

- (void)viewWillLayoutSubviews {
    [self updateFrames];
    [self updateCameraReticule];
}

- (void)updateFrames {
    self.videoPreviewView.frame = self.view.bounds;
    self.manualEntryView.frame = CGRectMake(0, CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) * (1.0f - kGLManualEntryViewPositionRatio));
}

- (void)updateCameraReticule {
    [self.targetingReticule removeFromSuperlayer];
    
    CGRect bounds = self.view.bounds;
    const CGFloat sideLength = CGRectGetWidth(bounds) * 0.5;
    CGRect cameraRect = CGRectMake(CGRectGetMidX(bounds) - sideLength * 0.5, CGRectGetMidY(bounds) - sideLength * 0.5, sideLength, sideLength);
    
    self.targetingReticule = [[GLCameraLayer alloc] initWithBounds:cameraRect cornerRadius:10 lineLength:4];
    [self.view.layer addSublayer:self.targetingReticule];
    self.targetingReticule.opacity = 0;
}

#pragma mark - Scanning View Management

- (void)displayManualEntryView {
    [GLProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Item not found - Please enter"]];
    
    [self.view addSubview:self.manualEntryView];
    [self.manualEntryViewDismissHandler presentViewWithVelocity:0];
}

- (RACSignal *)dismissManualEntryView {
    [self.barcodeScanner resume];
    
    return [[self.manualEntryViewDismissHandler dismissViewWithVelocity:0] doCompleted:^{
        [self.manualEntryView removeFromSuperview];
    }];
}

- (void)willDismissViewAfterUserInteraction {
    [self.barcodeScanner resume];
}

#pragma mark - Appearance

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - UITableViewControllerDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:@"SearchItem" forIndexPath:indexPath];
}

#pragma mark - IBActions

- (IBAction)didTapDoneButton:(UIButton *)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didTapScanningButton:(UIButton *)sender {
    POPSpringAnimation *scale = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scale.fromValue = [NSValue valueWithCGPoint:CGPointMake(1, 1)];
    scale.toValue = [NSValue valueWithCGPoint:CGPointMake(2, 2)];
    scale.springSpeed = 12;
    scale.springBounciness = 0;
    scale.name = @"scaleBlurViewLayer";
    
    POPSpringAnimation *fade = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerOpacity];
    fade.fromValue = @1;
    fade.toValue = @0;
    fade.springSpeed = 10;
    fade.springBounciness = 0;
    fade.name = @"fadeBlurViewLayer";
    
    POPSpringAnimation *show = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerOpacity];
    show.fromValue = @0;
    show.toValue = @1;
    fade.springSpeed = 10;
    fade.springBounciness = 0;
    show.name = @"showTargetingReticule";
    
    [self.animationStack pushAnimation:scale withTargetObject:self.blurView.layer andDescription:@"scale"];
    [self.animationStack pushAnimation:fade withTargetObject:self.blurView.layer andDescription:@"fade"];
    [self.animationStack pushAnimation:show withTargetObject:self.targetingReticule andDescription:@"show"];
}

#pragma mark - Keyboard Responder Delegate

- (UIView *)viewToAnimateForKeyboardAdjustment {
    return self.manualEntryView;
}

- (UIView *)viewForActiveUserInputElement {
    return self.manualEntryView.activeField;
}

#pragma mark - Lazy Instantiation

- (GLManualEntryView *)manualEntryView {
    if (!_manualEntryView) {
        _manualEntryView = [[GLManualEntryView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) * (1.0f - kGLManualEntryViewPositionRatio))];
        
        RAC(_manualEntryView.name, enabled) = [_manualEntryView.name.rac_textSignal map:^id(NSString *value) {
            return @([value length] >= 1);
        }];
    }
    
    return _manualEntryView;
}

- (GLVideoPreviewView *)videoPreviewView {
    if (!_videoPreviewView) {
        [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([GLVideoPreviewView class]) owner:self options:nil];
        _videoPreviewView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
        _videoPreviewView.doneScanningItemsButton.rac_command = [[RACCommand alloc] initWithSignalBlock:self.doneScanningBlock];
        AVCaptureVideoPreviewLayer *layer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.barcodeScanner.captureSession];
        layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _videoPreviewView.capturePreviewLayer = layer;
    }
    
    return _videoPreviewView;
}

- (GLDismissableViewHandler *)manualEntryViewDismissHandler {
    if (!_manualEntryViewDismissHandler) {
        _manualEntryViewDismissHandler = [[GLDismissableViewHandler alloc] initWithView:self.manualEntryView finalPosition:CGRectGetHeight(self.view.bounds) * kGLManualEntryViewPositionRatio];
        
        UIPanGestureRecognizer *swipeDownToDismiss = [[UIPanGestureRecognizer alloc] initWithTarget:_manualEntryViewDismissHandler action:@selector(handlePan:)];
        [self.view addGestureRecognizer:swipeDownToDismiss];
        swipeDownToDismiss.delegate = self.manualEntryViewDismissHandler;
        
        self.manualEntryViewDismissHandler.delegate = self;
    }
    
    return _manualEntryViewDismissHandler;
}

- (GLScanningSession *)barcodeScanner {
    if (!_barcodeScanner) {
        self.barcodeScanner = [GLScanningSession session];
    }
    return _barcodeScanner;
}

- (GLBarcodeFetchManager *)barcodeManager {
    if (!_barcodeManager) {
        self.barcodeManager = [[GLBarcodeFetchManager alloc] init];
    }
    return _barcodeManager;
}

- (GLTransitionDelegate *)transitionDelegate
{
    if (!_transitionDelegate) {
        _transitionDelegate = [[GLTransitionDelegate alloc] initWithController:self presentationController:[GLPullToCloseTransitionPresentationController class] transitionManager:[GLPullToCloseTransitionManager class]];
    }
    
    return _transitionDelegate;
}

@end