//
//  GLScannerViewController.m
//  GroceryList
//
//  Created by Hakon Hanesand on 2/11/15.

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <Pop/POP.h>
#import <SVProgressHUD/SVProgressHUD.h>

#import "GLScannerViewController.h"
#import "GLItemConfirmationView.h"
#import "GLScanningSession.h"
#import "GLBarcode.h"
#import "GLCameraLayer.h"
#import "GLBarcodeFetchManager.h"
#import "GLPullToCloseTransitionManager.h"
#import "GLPullToCloseTransitionPresentationController.h"

#import "POPAnimation+GLAnimation.h"
#import "GLListObject.h"

typedef RACSignal* (^RACCommandBlock)(id);

@interface GLScannerViewController()
@property (nonatomic, copy) RACCommandBlock confirmCommand;
@property (nonatomic, copy) RACCommandBlock cancelCommand;
@property (nonatomic, copy) RACCommandBlock doneScanningBlock;

@property (nonatomic) GLPullToCloseTransitionManager *transitionManager;
@property (nonatomic) GLPullToCloseTransitionPresentationController *presentationController;
@property (nonatomic) GLDismissableViewHandler *confirmationViewDismissHandler;

@property (nonatomic) GLBarcodeFetchManager *barcodeManager;
@property (nonatomic) GLScanningSession *barcodeScanner;

@property (strong, nonatomic) IBOutlet GLVideoPreviewView *videoPreviewView;
@property (nonatomic) GLItemConfirmationView *itemConfirmationView;
@property (nonatomic) GLCameraLayer *targetingReticule;

@property (nonatomic) GLListObject *currentListItem;
@end

static NSString *identifier = @"GLBarcodeItemTableViewCell";

@implementation GLScannerViewController

- (instancetype)init {
    if (self = [super initWithNibName:NSStringFromClass([GLScannerViewController class]) bundle:[NSBundle mainBundle]]) {
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.transitioningDelegate = self;
        self.modalPresentationCapturesStatusBarAppearance = YES;
        
        self.barcodeScanner = [GLScanningSession session];
        self.barcodeManager = [[GLBarcodeFetchManager alloc] init];
        
        [self setupRACCommands];
        [self configureKeyboardAnimations];
    }
    
    return self;
}

- (void)setupRACCommands {
    @weakify(self);
    self.confirmCommand = ^RACSignal *(id input) {
        @strongify(self);
        [self.delegate didRecieveNewListItem:self.currentListItem];
        [self.barcodeScanner resume];
        
        return [[self dismissManualEntryView] doCompleted:^{
            [self.confirmationView removeFromSuperview];
        }];
    };
    
    self.cancelCommand = ^RACSignal *(id input) {
        @strongify(self);
        [self.barcodeScanner resume];
        
        return [[self dismissManualEntryView] doCompleted:^{
            [self.confirmationView removeFromSuperview];
        }];
    };
    
    self.doneScanningBlock = ^RACSignal *(id input) {
        @strongify(self);
        [self.barcodeScanner resume];
        return [self.animationStack popAllAnimations];
    };
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initializeVideoPreviewLayer];
}

- (void)initializeVideoPreviewLayer {
    self.videoPreviewView.capturePreviewLayer = self.barcodeScanner.previewLayer;
    
    UITapGestureRecognizer *doubleTapTestingScan = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(testScanning)];
    doubleTapTestingScan.numberOfTapsRequired = 2;
    [self.videoPreviewView addGestureRecognizer:doubleTapTestingScan];
    
    self.barcodeScanner.previewView = self.videoPreviewView;
    [self.barcodeScanner startScanningWithDelegate:self];
    
    [self.view insertSubview:self.videoPreviewView atIndex:0];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateBounds];
    [self initializeCameraReticule];
}

- (void)updateBounds {
    self.videoPreviewView.bounds = self.view.bounds;
}

- (void)initializeCameraReticule {
    [self.targetingReticule removeFromSuperlayer];
    
    CGRect bounds = self.view.bounds;
    const CGFloat sideLength = CGRectGetWidth(bounds) * 0.5;
    CGRect cameraRect = CGRectMake(CGRectGetMidX(bounds) - sideLength * 0.5, CGRectGetMidY(bounds) - sideLength * 0.5, sideLength, sideLength);
    
    self.targetingReticule = [[GLCameraLayer alloc] initWithBounds:cameraRect cornerRadius:10 lineLength:4];
    [self.view.layer addSublayer:self.targetingReticule];
    self.targetingReticule.opacity = 0;
}

#pragma mark - UIViewControllerTransitioningDelegate

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)to presentingViewController:(UIViewController *)from sourceViewController:(UIViewController *)source {
    if ([to isEqual:self]) {
        return [[GLPullToCloseTransitionPresentationController alloc] initWithPresentedViewController:to presentingViewController:from];
    }
    
    return nil;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)to presentingController:(UIViewController *)from sourceController:(UIViewController *)source {
    if ([to isEqual:self]) {
        self.transitionManager.presenting = YES;
        return self.transitionManager;
    }
    
    return nil;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    if ([dismissed isEqual:self]) {
        self.transitionManager.presenting = NO;
        return self.transitionManager;
    }
    
    return nil;
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

- (void)testScanning {//0012000001086
    [self scanner:self.barcodeScanner didRecieveBarcode:[GLBarcode barcodeWithBarcode:@"120182198491824142"]];
}

- (IBAction)didTapDoneButton:(UIButton *)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)resetViewPositions {
    self.blurView.layer.contentsScale = 1;
    self.blurView.layer.opacity = 1;
    self.targetingReticule.opacity = 0;
    [self.confirmationView removeFromSuperview];
    
    [self.animationStack.stack removeAllObjects];
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

#pragma mark - Barcode Scanner Delegate

- (void)scanner:(GLScanningSession *)scanner didRecieveBarcode:(GLBarcode *)barcode {
    [scanner pause];
    
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        @strongify(self);
        [[self.barcodeManager fetchProductInformationForBarcode:barcode] subscribeNext:^(GLListObject *listObject) {
            [self.delegate didRecieveNewListItem:listObject];
            [scanner resume];
        } error:^(NSError *error) {
            [self displayManualEntryView:[GLListObject objectWithCurrentUser]];
        }];
    });
}

- (void)displayManualEntryView:(GLListObject *)listObject {
    [self.confirmationView bindWithListObject:listObject];
    [self.view addSubview:self.confirmationView];
    
    POPSpringAnimation *presentConfirmationView = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionY];
    presentConfirmationView.fromValue = @(self.confirmationView.center.y);
    presentConfirmationView.toValue = @(CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.confirmationView.frame) * 0.5);
    presentConfirmationView.springBounciness = 0;
    presentConfirmationView.springSpeed = 20;
    presentConfirmationView.name = @"presentManualEntryView";
    
    [self.confirmationView pop_addAnimation:presentConfirmationView forKey:@"presentManualEntryView"];
    
    [self setupInteractiveDismissalOfConfirmationView];
}

- (void)setupInteractiveDismissalOfConfirmationView {
    UIPanGestureRecognizer *swipeDownToDismiss = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePullDownToDismissGestureRecognizer:)];
    [self.view addGestureRecognizer:swipeDownToDismiss];
    swipeDownToDismiss.delegate = self.confirmationViewDismissHandler;
    
    self.confirmationViewDismissHandler.delegate = self;
    self.confirmationViewDismissHandler.enabled = YES;
}

- (void)handlePullDownToDismissGestureRecognizer:(UIPanGestureRecognizer *)pan {
    [self.confirmationViewDismissHandler handlePan:pan];
}

- (void)willDismissViewAfterUserInteraction {
    [self.barcodeScanner resume];
}

- (RACSignal *)dismissManualEntryView {
    POPSpringAnimation *dismiss = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionY];
    dismiss.toValue = @(CGRectGetHeight(self.view.frame) + CGRectGetHeight(self.confirmationView.frame) / 2);
    dismiss.springSpeed = 20;
    dismiss.springBounciness = 0;
    dismiss.name = @"dismissConfirmationView";
    
    [self.confirmationView pop_addAnimation:dismiss forKey:@"manual_confirmation_view_dismiss"];
    
    self.confirmationViewDismissHandler.enabled = NO;
    
    return [dismiss completionSignal];
}

#pragma mark - Notification Center Keyboard Animations

- (void)configureKeyboardAnimations {
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification *notif) {
        //see http://stackoverflow.com/a/19236013/4080860
        
        CGRect keyboardFrame = [notif.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGRect activeFieldFrame = [self.view convertRect:self.confirmationView.activeField.frame fromView:self.confirmationView];
        
        if (CGRectGetMinY(keyboardFrame) - CGRectGetMaxY(activeFieldFrame) < 8) {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:[notif.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
            [UIView setAnimationCurve:[notif.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
            [UIView setAnimationBeginsFromCurrentState:YES];
            
            CGFloat intersectionDistance =  abs(CGRectGetMinY(keyboardFrame) - CGRectGetMaxY(activeFieldFrame)) + 8;
            self.confirmationView.frame = CGRectOffset(self.confirmationView.frame, 0, -intersectionDistance);
            
            [UIView commitAnimations];
        }
    }];
    
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillHideNotification object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification *notif) {
        //see http://stackoverflow.com/a/19236013/4080860
        
        CGFloat offset = CGRectGetHeight(self.view.frame) - CGRectGetMaxY(self.confirmationView.frame);
        
        if (roundf(offset) != 0) {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:[notif.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
            [UIView setAnimationCurve:[notif.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
            [UIView setAnimationBeginsFromCurrentState:YES];
            
            self.confirmationView.frame = CGRectOffset(self.confirmationView.frame, 0, roundf(offset));
            
            [UIView commitAnimations];
        }
    }];
}

#pragma mark - Lazy Getters

- (GLPullToCloseTransitionManager *)transitionManager {
    if (!_transitionManager) {
        _transitionManager = [[GLPullToCloseTransitionManager alloc] init];
    }
    
    return _transitionManager;
}

- (GLItemConfirmationView *)confirmationView {
    if (!_itemConfirmationView) {
        _itemConfirmationView = [[GLItemConfirmationView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) * 0.5)];
        _itemConfirmationView.cancel.rac_command = [[RACCommand alloc] initWithSignalBlock:self.cancelCommand];
        _itemConfirmationView.confirm.rac_command = [[RACCommand alloc] initWithSignalBlock:self.confirmCommand];
    }
    
    return _itemConfirmationView;
}

- (GLVideoPreviewView *)videoPreviewView {
    if (!_videoPreviewView) {
        [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([GLVideoPreviewView class]) owner:self options:nil];
        _videoPreviewView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
        _videoPreviewView.doneScanningItemsButton.rac_command = [[RACCommand alloc] initWithSignalBlock:self.doneScanningBlock];
    }
    
    return _videoPreviewView;
}

- (GLDismissableViewHandler *)confirmationViewDismissHandler
{
    if (!_confirmationViewDismissHandler) {
        _confirmationViewDismissHandler = [[GLDismissableViewHandler alloc] initWithView:self.itemConfirmationView];
    }
    
    return _confirmationViewDismissHandler;
}



@end
