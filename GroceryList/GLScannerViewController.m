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
#import "GLTweakCollection.h"
#import "POPAnimationExtras.h"
#import "GLTableViewController.h"
#import "GLScanningSession.h"
#import "PFQuery+GLQuery.h"
#import "GLBarcode.h"
#import "GLParseAnalytics.h"
#import "UIView+RecursiveInteraction.h"
#import "GLCameraLayer.h"
#import "GLBarcodeFetchManager.h"

#define TICK   NSDate *startTime = [NSDate date]
#define TOCK   NSLog(@"Time GLScannerViewController: %f", -[startTime timeIntervalSinceNow])

@interface GLScannerViewController()
@property (nonatomic) GLFactualManager *manager;
@property (nonatomic) GLBingFetcher *bing;
@property (nonatomic) GLScanningSession *barcodeScanner;
@property (nonatomic) NSDictionary *tweaksForConfirmAnimation;
@property (nonatomic) GLCameraLayer *targetingReticule;

@property (nonatomic) GLListObject *currentListItem;
@property (nonatomic) GLBarcodeFetchManager *barcodeManager;
@end

static NSString *identifier = @"GLBarcodeItemTableViewCell";

@implementation GLScannerViewController

- (instancetype)init {
    if (self = [super initWithNibName:@"GLScannerViewController" bundle:[NSBundle mainBundle]]) {
        self.manager = [[GLFactualManager alloc] init];
        self.bing = [GLBingFetcher sharedFetcher];
        self.barcodeScanner = [GLScanningSession session];
        [self.barcodeScanner startScanningWithDelegate:self];
        
        [self configureKeyboardAnimations];
    }
    
    return self;
}

#pragma mark - Lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.barcodeScanner.previewLayer.frame = self.view.frame;
    [self.barcodeScanner startScanningWithDelegate:self];

    UIView *videoPreviewView = [[UIView alloc] initWithFrame:self.view.bounds];
    [videoPreviewView.layer addSublayer:self.barcodeScanner.previewLayer];
    
    UITapGestureRecognizer *doubleTapTestingScan = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(testScanning)];
    doubleTapTestingScan.numberOfTapsRequired = 2;
    [videoPreviewView addGestureRecognizer:doubleTapTestingScan];
    
    [self.view insertSubview:videoPreviewView atIndex:0];
    
    CGRect bounds = self.view.bounds;
    const CGFloat sideLength = CGRectGetWidth(bounds) * 0.5;
    CGRect cameraRect = CGRectMake(CGRectGetMidX(bounds) - sideLength * 0.5, CGRectGetMidY(bounds) - sideLength * 0.5, sideLength, sideLength);
    
    self.targetingReticule = [[GLCameraLayer alloc] initWithBounds:cameraRect cornerRadius:10 lineLength:4];
    [self.view.layer addSublayer:self.targetingReticule];
    self.targetingReticule.opacity = 0;

    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(15, 0, CGRectGetWidth(self.tableView.frame) - 15, 1)];
    line.backgroundColor = self.tableView.separatorColor;
//    self.tableView.tableHeaderView = line;
}



#pragma mark - Scanner Delegate

- (IBAction)didTapScanningButton:(UIButton *)sender {
    POPSpringAnimation *scale = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scale.fromValue = [NSValue valueWithCGPoint:CGPointMake(1, 1)];
    scale.toValue = [NSValue valueWithCGPoint:CGPointMake(2, 2)];
    scale.springSpeed = 12;
    scale.springBounciness = 0;

    POPSpringAnimation *fade = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerOpacity];
    fade.fromValue = @1;
    fade.toValue = @0;
    fade.springSpeed = 10;
    fade.springBounciness = 0;

    POPSpringAnimation *show = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerOpacity];
    show.fromValue = @0;
    show.toValue = @1;
    fade.springSpeed = 10;
    fade.springBounciness = 0;
    
    [self.animationStack pushAnimation:scale withTargetObject:self.blurView.layer andDescription:@"scale"];
    [self.animationStack pushAnimation:fade withTargetObject:self.blurView.layer andDescription:@"fade"];
    [self.animationStack pushAnimation:show withTargetObject:self.targetingReticule andDescription:@"show"];
}

- (void)testScanning {
    [self scanner:self.barcodeScanner didRecieveBarcode:[GLBarcode barcodeWithBarcode:@"0012000001086"]];
}

- (void)scanner:(GLScanningSession *)scanner didRecieveBarcode:(GLBarcode *)barcode {
    [scanner stopScanning];
    
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [[self.barcodeManager fetchProductInformationForBarcode:barcode] subscribeNext:^(GLListObject *newListItem) {
            @weakify(self);
            self.currentListItem = newListItem;
            [self showConfirmationViewWithListItem:newListItem];
        }];
    });
}

- (void)showConfirmationViewWithListItem:(GLListObject *)listItem {
    [self.confirmationView bindWithListObject:listItem];
    [self.view addSubview:self.confirmationView];
    [self.confirmationView presentView];
}

- (void)shouldDismissDismissableView:(GLDismissableView *)view withVelocity:(CGFloat)velocity{
    //yes - so dismiss the view
    [self dismissConfirmationViewWithVelocity:velocity andPopAllAnimations:YES];
}

- (RACSignal *)dismissConfirmationViewWithVelocity:(CGFloat)velocity andPopAllAnimations:(BOOL)popAll {
    [self.barcodeScanner startScanningWithDelegate:self];
    
    RACSignal *dismissConfirmationViewSignal = [self.confirmationView dismissViewWithVelocity:velocity];
    
    if (popAll) {
        dismissConfirmationViewSignal = [dismissConfirmationViewSignal flattenMap:^RACStream *(id value) {
            return [self.animationStack popAllAnimations];
        }];
    }
    
    return [dismissConfirmationViewSignal doCompleted:^{
        [self.confirmationView removeFromSuperview];
    }];
}


- (GLItemConfirmationView *)confirmationView {
    if (!_confirmationView) {
        _confirmationView = [[GLItemConfirmationView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) * 0.5)];
        _confirmationView.delegate = self;
        
        RACSignal *canSubmitSignal = [self.confirmationView.name.rac_textSignal map:^id(NSString *name) {
            return @([name length] > 0);
        }];
        
        @weakify(self);
        _confirmationView.confirm.rac_command = [[RACCommand alloc] initWithEnabled:canSubmitSignal signalBlock:^RACSignal *(id input) {
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                @strongify(self);
                [self.delegate didRecieveNewListItem:self.currentListItem];
                [self dismissConfirmationViewWithVelocity:0 andPopAllAnimations:YES];
                return nil;
            }];
        }];
        
        self.confirmationView.cancel.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                @strongify(self);
                
                [self dismissConfirmationViewWithVelocity:0 andPopAllAnimations:NO];
                
                return nil;
            }];
        }];
    }
    
    return _confirmationView;
}

#pragma mark - Notification Center

- (void)configureKeyboardAnimations {
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification *notif) {
         //see http://stackoverflow.com/a/19236013/4080860
         
         CGRect keyboardFrame = [notif.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
         CGRect activeFieldFrame = [[self getWindow] convertRect:self.confirmationView.activeField.frame fromView:self.confirmationView];
         
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
         
         CGFloat offset = CGRectGetHeight([self getWindow].frame) - CGRectGetMaxY(self.confirmationView.frame);
         
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

- (UIWindow *)getWindow {
    return [[UIApplication sharedApplication] keyWindow];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:@"SearchItem" forIndexPath:indexPath];
}

#pragma mark - GLDismissableViewDelegate

- (CGFloat)finalPositionForDismissableView:(GLDismissableView *)view inState:(GLDismissableViewState)state {
    switch (state) {
        case GLDismissableViewStatePresented:
            return CGRectGetHeight(self.view.frame) - CGRectGetHeight(view.frame) * 0.5;
            
        case GLDismissableViewStateDismissed:
            return CGRectGetMaxY(self.view.frame) + CGRectGetMidY(view.frame);
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
