//
//  CAScannerViewController.m
//  GroceryList
//
//  Created by Hakon Hanesand on 2/11/15.

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <Pop/POP.h>
#import <SVProgressHUD/SVProgressHUD.h>

#import "CAScannerViewController.h"
#import "CAManualEntryView.h"
#import "CAScanningSession.h"
#import "CABarcode.h"
#import "CACameraLayer.h"
#import "CABarcodeFetchManager.h"
#import "CAPullToCloseTransitionManager.h"
#import "CAPullToCloseTransitionPresentationController.h"

#import "POPAnimation+CAAnimation.h"
#import "JVFloatLabeledTextField.h"
#import "CATransitionDelegate.h"
#import "CAKeyboardResponderAnimator.h"
#import "CABarcodeObject.h"
#import "CAProgressHUD.h"
#import "CAListObject.h"

typedef RACSignal* (^RACCommandBlock)(id);

@interface CAScannerViewController()
@property (weak, nonatomic) UITextField *activeField;

@property (weak, nonatomic) IBOutlet CAManualEntryView *manualEntryView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *manualLayoutBottomConstraint;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *searchView;
@property (strong, nonatomic) IBOutlet CAVideoPreviewView *videoPreviewView;

@property (nonatomic, copy) RACCommandBlock doneScanningBlock;

@property (nonatomic) CATransitionDelegate *transitionDelegate;
@property (nonatomic) CADismissableViewHandler *manualEntryViewDismissHandler;

@property (nonatomic) CAKeyboardResponderAnimator *responder;

@property (nonatomic) CABarcodeFetchManager *barcodeManager;
@property (nonatomic) CAScanningSession *barcodeScanner;

@property (nonatomic) CACameraLayer *targetingReticule;
@end

static NSString *identifier = @"CABarcodeItemTableViewCell";

@implementation CAScannerViewController

#pragma mark - Setup

+ (instancetype)instance {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:NSStringFromClass([self class]) bundle:nil];
    return [storyboard instantiateInitialViewController];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
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
    
    [self.view endEditing:YES];
    
    [self initializeKeyboardAnimations];
    [self initializeVideoPreviewLayer];
    [self initializeManualEntryView];
    [self subscribeToBarcodeScannerOutput];
}

- (void)initializeKeyboardAnimations {
    self.responder = [[CAKeyboardResponderAnimator alloc] initWithDelegate:self];
}

- (void)initializeVideoPreviewLayer {
    @weakify(self);
    self.videoPreviewView.doneScanningItemsButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        [self.barcodeScanner resume];
        return [[self.animationStack popAllAnimations] doCompleted:^{
            NSLog(@"Completed");
        }];
    }];
    
    AVCaptureVideoPreviewLayer *layer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.barcodeScanner.captureSession];
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.videoPreviewView.capturePreviewLayer = layer;
}

- (void)initializeManualEntryView {
    RAC(_manualEntryView.confirm, enabled) = [_manualEntryView.name.rac_textSignal map:^id(NSString *value) {
        return @([value length] >= 1);
    }];
    
    UIPanGestureRecognizer *swipeDownToDismiss = [[UIPanGestureRecognizer alloc] initWithTarget:self.manualEntryViewDismissHandler action:@selector(handlePan:)];
    [self.view addGestureRecognizer:swipeDownToDismiss];
    swipeDownToDismiss.delegate = self.manualEntryViewDismissHandler;
    
    self.manualEntryViewDismissHandler.delegate = self;
}

- (void)subscribeToBarcodeScannerOutput {
    self.listItemSignal = [[[[self.barcodeScanner.barcodeSignal doNext:^(id x) {
        [CAProgressHUD show];
        [self.barcodeScanner pause];
    }] flattenMap:^RACStream *(CABarcode *barcode) {
        return [[self.barcodeManager fetchProductInformationForBarcode:barcode] catch:^RACSignal *(NSError *error) {
            [self displayManualEntryView];
            
            RACSignal *confirm = [[self.manualEntryView.confirm rac_signalForControlEvents:UIControlEventTouchUpInside] map:^id(id _) {
                return [CABarcodeObject objectWithName:self.manualEntryView.name.text];
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
    }] doNext:^(CABarcodeObject *barcodeObject) {
        [CAProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"Added %@", barcodeObject.name]];
        [self.barcodeScanner resume];
    }] logNext];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    [self updateCameraReticule];
}

- (void)updateCameraReticule {
    [self.targetingReticule removeFromSuperlayer];
    
    CGRect bounds = self.view.bounds;
    const CGFloat sideLength = CGRectGetWidth(bounds) * 0.5;
    CGRect cameraRect = CGRectMake(CGRectGetMidX(bounds) - sideLength * 0.5, CGRectGetMidY(bounds) - sideLength * 0.5, sideLength, sideLength);
    
    self.targetingReticule = [[CACameraLayer alloc] initWithBounds:cameraRect cornerRadius:10 lineLength:4];
    [self.view.layer addSublayer:self.targetingReticule];
    self.targetingReticule.opacity = 0;
}

#pragma mark - Scanning View Management

- (void)displayManualEntryView {
    [CAProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Item not found - Please enter"]];
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
    [self.view endEditing:YES];
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
    scale.name = @"scaleSearchViewLayer";
    
    POPSpringAnimation *fade = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerOpacity];
    fade.fromValue = @1;
    fade.toValue = @0;
    fade.springSpeed = 10;
    fade.springBounciness = 0;
    fade.name = @"fadeSearchViewLayer";
    
    POPSpringAnimation *show = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerOpacity];
    show.fromValue = @(0.0);
    show.toValue = @(1.0);
    show.springSpeed = 10;
    show.springBounciness = 0;
    show.name = @"showTargetingReticule";
    
    POPSpringAnimation *show1 = [POPSpringAnimation animationWithPropertyNamed:kPOPViewAlpha];
    show1.fromValue = @(0.0);
    show1.toValue = @(1.0);
    show1.springSpeed = 10;
    show1.springBounciness = 0;
    show1.name = @"showButton";
    
    [self.animationStack pushAnimation:scale withTargetObject:self.searchView.layer andDescription:@"scale"];
    [self.animationStack pushAnimation:fade withTargetObject:self.searchView.layer andDescription:@"fade"];
    [self.animationStack pushAnimation:show withTargetObject:self.targetingReticule andDescription:@"show"];
    [self.animationStack pushAnimation:show1 withTargetObject:self.videoPreviewView.doneScanningItemsButton andDescription:@"show1"];
}

- (void)pop_animationDidApply:(POPAnimation *)anim {
    NSLog(@"Animaion did apply");
}

#pragma mark - Keyboard Responder Delegate

- (UIView *)viewToAnimateForKeyboardAdjustment {
    return self.manualEntryView;
}

- (UIView *)viewForActiveUserInputElement {
    return self.manualEntryView.activeField;
}

- (NSLayoutConstraint *)layoutConstraintForAnimatingView {
    return self.manualLayoutBottomConstraint;
}

#pragma mark - Lazy Instantiation

- (CADismissableViewHandler *)manualEntryViewDismissHandler {
    if (!_manualEntryViewDismissHandler) {
        self.manualEntryViewDismissHandler = [[CADismissableViewHandler alloc] initWithAnimatableView:self.manualEntryView superViewHeight:CGRectGetHeight(self.view.frame)  animatableConstraint:self.manualLayoutBottomConstraint];
    }
    
    return _manualEntryViewDismissHandler;
}

- (CAScanningSession *)barcodeScanner {
    if (!_barcodeScanner) {
        self.barcodeScanner = [CAScanningSession session];
    }
    return _barcodeScanner;
}

- (CABarcodeFetchManager *)barcodeManager {
    if (!_barcodeManager) {
        self.barcodeManager = [[CABarcodeFetchManager alloc] init];
    }
    return _barcodeManager;
}

- (CATransitionDelegate *)transitionDelegate
{
    if (!_transitionDelegate) {
        _transitionDelegate = [[CATransitionDelegate alloc] initWithController:self presentationController:[CAPullToCloseTransitionPresentationController class] transitionManager:[CAPullToCloseTransitionManager class]];
    }
    
    return _transitionDelegate;
}

@end