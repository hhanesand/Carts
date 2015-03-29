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
#import "GLBarcodeManager.h"
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

#define TICK   NSDate *startTime = [NSDate date]
#define TOCK   NSLog(@"Time GLScannerViewController: %f", -[startTime timeIntervalSinceNow])

@interface GLScannerViewController()
@property (nonatomic) GLBarcodeManager *manager;
@property (nonatomic) GLBingFetcher *bing;
@property (nonatomic) GLScanningSession *barcodeScanner;
@property (nonatomic) NSDictionary *tweaksForConfirmAnimation;
@property (nonatomic) GLCameraLayer *targetingReticule;
@end

static NSString *identifier = @"GLBarcodeItemTableViewCell";

@implementation GLScannerViewController

- (instancetype)init {
    if (self = [super initWithNibName:@"GLScannerViewController" bundle:[NSBundle mainBundle]]) {
        self.manager = [[GLBarcodeManager alloc] init];
        self.bing = [GLBingFetcher sharedFetcher];
        self.barcodeScanner = [GLScanningSession session];
        [self.barcodeScanner startScanningWithDelegate:self];
        
        [self rac];
        [self tweak];
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - Scanner Delegate
//present the camera view that is lying in the background
- (IBAction)didTapScanningButton:(UIButton *)sender {
    //layer scale somehow works better than the view scale... don't know why
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
    [SVProgressHUD show];
    [scanner stopScanning];
    
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [[[[[self fetchProductInformationForBarcode:barcode] deliverOnMainThread] doNext:^(id x) {
            //show success before we catch for the failure so user can tell his item info was found
            [SVProgressHUD showSuccessWithStatus:@"Item found!"];
        }] catch:^RACSignal *(NSError *error) {
            //neither parse nor factual have any information (or net error) about this item so we'll make an empty one for user to fill out
            [SVProgressHUD showErrorWithStatus:@"Item not found"];
            return [RACSignal return:[GLListObject objectWithCurrentUser]];
        }] subscribeNext:^(GLListObject *newListItem) {
            @strongify(self);
            [self showConfirmationViewWithListItem:newListItem];
        }];
    });
}

//prepare confirmation view and add background scale + opacity animation and the custom present animation
- (void)showConfirmationViewWithListItem:(GLListObject *)listItem {
    GLItemConfirmationView *confirmationView = [self prepareConfirmationViewWithListItem:listItem];
    
    POPSpringAnimation *presentConfirmationView = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
    presentConfirmationView.fromValue = [NSValue valueWithCGPoint:confirmationView.center];
    presentConfirmationView.toValue = [NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetHeight(self.view.frame) - CGRectGetHeight(confirmationView.frame) * 0.5)];
    presentConfirmationView.springBounciness = [self.tweaksForConfirmAnimation[@"Spring Bounce"] floatValue];
    presentConfirmationView.springSpeed = [self.tweaksForConfirmAnimation[@"Spring Speed"] floatValue];
    
    [self.view addSubview:confirmationView];
    [self.animationStack pushAnimation:presentConfirmationView withTargetObject:confirmationView andDescription:@"presentConfirmationView"];
    
    self.confirmationView = confirmationView; //weak pointer so set after we add it to the subview
}

//sets up a confirmation view that tells the delegate when the user has clicked the confirm button and passes the list item to it
- (GLItemConfirmationView *)prepareConfirmationViewWithListItem:(GLListObject *)list {
    CGRect popupViewSize = CGRectMake(0, CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) * 0.5);
    
    GLItemConfirmationView *confirmationView = [[GLItemConfirmationView alloc] initWithFrame:popupViewSize];
    [confirmationView bindWithListObject:list];
    
    RACSignal *canSubmitSignal = [confirmationView.name.rac_textSignal map:^id(NSString *name) {
        return @([name length] > 0);
    }];
    
    @weakify(self);
    confirmationView.confirm.rac_command = [[RACCommand alloc] initWithEnabled:canSubmitSignal signalBlock:^RACSignal *(id input) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
            [self.delegate didRecieveNewListItem:list];
            
            [[self.animationStack popAllAnimations] subscribeCompleted:^{
                NSLog(@"Completed poping animations");
            }];
            
            return nil;
        }];
    }];
    
//    confirmationView.cancel.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
//        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//            @strongify(self);
//            
//            [self.barcodeScanner startScanningWithDelegate:self];
//            
//            CGAffineTransform translate = CGAffineTransformMakeTranslation(0, CGRectGetHeight(self.confirmationView.frame));
//            POPSpringAnimation *dismiss = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
//            dismiss.toValue = [NSValue valueWithCGPoint:CGPointApplyAffineTransform(self.confirmationView.center, translate)];
//            dismiss.springBounciness = [self.tweaksForConfirmAnimation[@"Spring Bounce"] floatValue];
//            dismiss.springSpeed = [self.tweaksForConfirmAnimation[@"Spring Speed"] floatValue];
//            
//            [self.confirmationView pop_addAnimation:dismiss forKey:@"dimiss"];
//            
//            [[dismiss addRACSignalToAnimation] subscribeCompleted:^{
//                [self.confirmationView removeFromSuperview];
//                [subscriber sendCompleted];
//            }];
//            
//            return nil;
//        }];
//    }];
    
    return confirmationView;
}

#pragma mark - Networking

- (PFQuery *)queryForBarcode:(GLBarcode *)item {
    PFQuery *query = [GLBarcodeObject query];
    [query whereKey:@"barcodes" equalTo:item.barcode];
    return query;
}

- (RACSignal *)fetchProductInformationForBarcode:(GLBarcode *)barcode {
    PFQuery *productQuery = [self queryForBarcode:barcode];
    
    @weakify(self);
    return [[[productQuery getFirstObjectWithRACSignal] catch:^RACSignal *(NSError *error) {
        @strongify(self);
        return [[self fetchProductInformationFromFactualForBarcode:barcode] doError:^(NSError *error) {
            [[GLParseAnalytics shared] trackMissingBarcode:barcode.barcode];
        }];
    }] map:^GLListObject *(GLBarcodeObject *value) {
        return [GLListObject objectWithCurrentUserAndBarcodeItem:value];
    }];
}

- (RACSignal *)fetchProductInformationFromFactualForBarcode:(GLBarcode *)barcode {
    return [[[self.manager queryFactualForBarcode:barcode.barcode] map:^id(NSDictionary *itemInformation) {
        return [GLBarcodeObject objectWithDictionary:itemInformation];
    }] flattenMap:^RACStream *(GLBarcodeObject *barcode) {
        return [self.bing fetchImageURLFromBingForBarcodeObject:barcode];
    }];
}


#pragma mark - Tweaks

- (void)tweak {
    self.tweaksForConfirmAnimation = @{@"Spring Speed" : @(20), @"Spring Bounce" : @(0)};
    [GLTweakCollection defineTweakCollectionInCategory:@"Animations" collection:@"Present Confirm View" withType:GLTWeakPOPSpringAnimation andObserver:self];
}

- (void)tweakCollection:(GLTweakCollection *)collection didChangeTo:(NSDictionary *)values {
    if ([collection.name isEqualToString:@"Present Confirm View"]) {
        NSLog(@"Tweaks changed to %@", values);
        self.tweaksForConfirmAnimation = values;
    }
}

- (void)rac {
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil]
      takeUntil:self.rac_willDeallocSignal]
     subscribeNext:^(NSNotification *notif) {
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
    
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillHideNotification object:nil]
      takeUntil:self.rac_willDeallocSignal]
     subscribeNext:^(NSNotification *notif) {
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

- (UIView *)getTopView {
    return [self getWindow].subviews[0];
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

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(15, 0, CGRectGetWidth(self.tableView.frame) - 15, 1 / [UIScreen mainScreen].scale)];
    line.backgroundColor = self.tableView.separatorColor;
    return line;
}

@end
