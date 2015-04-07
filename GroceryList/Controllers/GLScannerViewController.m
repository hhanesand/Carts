//
//  GLScannerViewController.m
//  GroceryList
//
//  Created by Hakon Hanesand on 2/11/15.
//
//

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <Pop/POP.h>

#import "RACSubject.h"

#import "SVProgressHUD.h"

#import "GLScannerViewController.h"
#import "GLFactualManager.h"
#import "GLBingFetcher.h"
#import "GLItemConfirmationView.h"
#import "GLListObject.h"
#import "GLBarcodeObject.h"
#import "UIColor+GLColor.h"
#import "POPSpringAnimation+GLAdditions.h"
#import "POPAnimationExtras.h"
#import "GLTableViewController.h"
#import "GLScanningSession.h"
#import "PFQuery+GLQuery.h"
#import "GLBarcode.h"
#import "GLParseAnalytics.h"
#import "UIView+RecursiveInteraction.h"
#import "GLCameraLayer.h"
#import "GLBarcodeFetchManager.h"
#import "GLDismissableViewHandler.h"
#import "POPAnimation+GLAnimation.h"
#import "GLPullToCloseTransitionManager.h"
#import "GLPullToCloseTransitionPresentationController.h"

#define TICK   NSDate *startTime = [NSDate date]
#define TOCK   NSLog(@"Time GLScannerViewController: %f", -[startTime timeIntervalSinceNow])

typedef RACSignal* (^RACCommandBlock)(id);

@interface GLScannerViewController()
@property (nonatomic, copy) RACCommandBlock confirmCommand;
@property (nonatomic, copy) RACCommandBlock cancelCommand;

@property (nonatomic) GLPullToCloseTransitionManager *transitionManager;
@property (nonatomic) GLPullToCloseTransitionPresentationController *presentationController;
@property (nonatomic) GLDismissableViewHandler *confirmationViewDismissHandler;

@property (nonatomic) GLBarcodeFetchManager *barcodeManager;
@property (nonatomic) GLScanningSession *barcodeScanner;

@property (nonatomic) GLItemConfirmationView *confirmationView;
@property (nonatomic) GLCameraLayer *targetingReticule;

@property (nonatomic) GLListObject *currentListItem;
@end

static NSString *identifier = @"GLBarcodeItemTableViewCell";

@implementation GLScannerViewController

- (instancetype)init {
    if (self = [super initWithNibName:NSStringFromClass([GLScannerViewController class]) bundle:[NSBundle mainBundle]]) {
        [self.barcodeScanner startScanningWithDelegate:self];
        
        [self configureKeyboardAnimations];
        [self setupRACCommands];
        
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.transitioningDelegate = self;
    }
    
    return self;
}

- (void)setupRACCommands {
    @weakify(self);
    //the block run when the user presses confirm -> should save the item scanned
    self.confirmCommand = ^RACSignal *(id input) {
        @strongify(self);
        //notify delegate (table view with all items scanned) of new item and restart the scanner
        [self.delegate didRecieveNewListItem:self.currentListItem];
        [self.barcodeScanner resumeWithDelegate:self];
        
        //pop all animations from the stack after confirmation view is dismissed
        return [[[self dismissConfirmationView] flattenMap:^RACStream *(id value) {
            return [self.animationStack popAllAnimations];
        }] doCompleted:^{
            [self.confirmationView removeFromSuperview];
        }];
    };
    
    //block called when the user presses cancel -> should not save the item scanned
    self.cancelCommand = ^RACSignal *(id input) {
        @strongify(self);
        [self.barcodeScanner resumeWithDelegate:self];
        
        //pop all animations from the stack after confirmation view is dismissed
        return [[self dismissConfirmationView] doCompleted:^{
            [self.confirmationView removeFromSuperview];
        }];
    };

}

#pragma mark - Lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self initializeVideoPreviewLayer];
    [self initializeCameraReticule];
}

- (void)initializeVideoPreviewLayer {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self.barcodeScanner startScanningWithDelegate:self];
    });
    
    self.barcodeScanner.previewView.frame = self.view.bounds;

    UITapGestureRecognizer *doubleTapTestingScan = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(testScanning)];
    doubleTapTestingScan.numberOfTapsRequired = 2;
    [self.barcodeScanner.previewView addGestureRecognizer:doubleTapTestingScan];
    
    [self.view insertSubview:self.barcodeScanner.previewView atIndex:0];
}

- (void)initializeCameraReticule {
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
        return self.presentationController;
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

- (void)testScanning {
    [self scanner:self.barcodeScanner didRecieveBarcode:[GLBarcode barcodeWithBarcode:@"0012000001086"]];
}

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

#pragma mark - Barcode Scanner Delegate

- (void)scanner:(GLScanningSession *)scanner didRecieveBarcode:(GLBarcode *)barcode {
    [scanner pause];
    
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [[self.barcodeManager fetchProductInformationForBarcode:barcode] subscribeNext:^(GLListObject *newListItem) {
            @strongify(self);
            self.currentListItem = newListItem;
            [self showConfirmationViewWithListItem:newListItem];
        }];
    });
}

- (void)showConfirmationViewWithListItem:(GLListObject *)listItem {
    [self.confirmationView bindWithListObject:listItem];
    [self.view addSubview:self.confirmationView];
    
    POPSpringAnimation *presentConfirmationView = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionY];
    presentConfirmationView.fromValue = @(self.confirmationView.center.y);
    presentConfirmationView.toValue = @(CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.confirmationView.frame) * 0.5);
    presentConfirmationView.springBounciness = 0;
    presentConfirmationView.springSpeed = 20;
    presentConfirmationView.name = @"presentConfirmationView";
    
    [self.confirmationView pop_addAnimation:presentConfirmationView forKey:@"presentConfirmationView"];
    
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


#pragma mark - Dismissable View Handler Delegate

- (void)willDismissViewAfterUserInteraction {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        self.confirmationViewDismissHandler.enabled = NO;
        [self.barcodeScanner resumeWithDelegate:self];
    });
}

- (RACSignal *)dismissConfirmationView {
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
         
         if (CGRectIntersectsRect(keyboardFrame, activeFieldFrame)) {
             [UIView beginAnimations:nil context:NULL];
             [UIView setAnimationDuration:[notif.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
             [UIView setAnimationCurve:[notif.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
             [UIView setAnimationBeginsFromCurrentState:YES];
             
             CGFloat intersectionDistance =  CGRectGetMaxY(activeFieldFrame) - CGRectGetMinY(keyboardFrame);
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

- (GLDismissableViewHandler *)confirmationViewDismissHandler {
    if (!_confirmationViewDismissHandler) {
        RACSignal *canSubmitSignal = [self.confirmationView.name.rac_textSignal map:^id(NSString *name) {
            return @([name length] > 0);
        }];
        
        //initialize confirmation view and hook up rac command blocks defined in the initializer
        _confirmationViewDismissHandler = [[GLDismissableViewHandler alloc] initWithView:self.confirmationView];
        _confirmationView.confirm.rac_command = [[RACCommand alloc] initWithEnabled:canSubmitSignal signalBlock:self.confirmCommand];
        _confirmationView.cancel.rac_command = [[RACCommand alloc] initWithSignalBlock:self.cancelCommand];
    }
    
    return _confirmationViewDismissHandler;
}

- (GLPullToCloseTransitionManager *)transitionManager {
    if (!_transitionManager) {
        _transitionManager = [[GLPullToCloseTransitionManager alloc] init];
    }
    
    return _transitionManager;
}

- (GLPullToCloseTransitionPresentationController *)presentationController {
    if (!_presentationController) {
        _presentationController = [[GLPullToCloseTransitionPresentationController alloc] init];
    }
    
    return _presentationController;
}

- (GLItemConfirmationView *)confirmationView {
    if (!_confirmationView) {
        _confirmationView = [[GLItemConfirmationView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) * 0.5)];
    }
    
    return _confirmationView;
}

- (GLBarcodeFetchManager *)barcodeManager {
    if (!_barcodeManager) {
        _barcodeManager = [[GLBarcodeFetchManager alloc] init];
    }
    
    return _barcodeManager;
}

- (GLScanningSession *)barcodeScanner {
    if (!_barcodeScanner) {
        _barcodeScanner = [GLScanningSession session];
    }
    
    return _barcodeScanner;
}


@end
