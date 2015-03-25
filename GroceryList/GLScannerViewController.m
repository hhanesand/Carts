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
#import "POPPropertyAnimation+GLAdditions.h"
#import "GLTweakCollection.h"
#import "POPAnimationExtras.h"
#import "GLTableViewController.h"
#import "GLScanningSession.h"
#import "PFQuery+GLQuery.h"
#import "GLBarcode.h"
#import "GLParseAnalytics.h"
#import "UIView+RecursiveInteraction.h"

#define TICK   NSDate *startTime = [NSDate date]
#define TOCK   NSLog(@"Time GLScannerViewController: %f", -[startTime timeIntervalSinceNow])

@interface GLScannerViewController()
@property (nonatomic) GLBarcodeManager *manager;
@property (nonatomic) GLBingFetcher *bing;
@property (nonatomic) GLScanningSession *scanning;
@property (nonatomic) NSDictionary *tweaksForConfirmAnimation;
@end

static NSString *identifier = @"GLBarcodeItemTableViewCell";

@implementation GLScannerViewController

- (instancetype)init {
    if (self = [super initWithNibName:@"GLScannerViewController" bundle:[NSBundle mainBundle]]) {
        self.manager = [[GLBarcodeManager alloc] init];
        self.bing = [GLBingFetcher sharedFetcher];
        self.scanning = [GLScanningSession session];
        
        [self rac];
        [self tweak];
    }
    
    return self;
}

#pragma mark - Lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.scanning.previewLayer.frame = self.view.frame;
    self.scanning.delegate = self;
    [self.scanning startScanning];
    
    UIView *videoPreviewView = [[UIView alloc] initWithFrame:self.view.frame];
    [videoPreviewView.layer addSublayer:self.scanning.previewLayer];
    
    UITapGestureRecognizer *doubleTapTestingScan = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(testScanning)];
    doubleTapTestingScan.numberOfTapsRequired = 2;
    [videoPreviewView addGestureRecognizer:doubleTapTestingScan];
    
    [self.view addSubview:videoPreviewView];
    [self.view sendSubviewToBack:videoPreviewView];

    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(15, 0, CGRectGetWidth(self.tableView.frame) - 15, 1 / [UIScreen mainScreen].scale)];
    line.backgroundColor = self.tableView.separatorColor;
    self.tableView.tableHeaderView = line;
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
    NSLog(@"Logging");
    POPSpringAnimation *lift = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    lift.fromValue = [NSValue valueWithCGPoint:CGPointMake(1, 1)];
    lift.toValue = [NSValue valueWithCGPoint:CGPointMake(2, 2)];
    lift.springSpeed = 15;
    lift.springBounciness = 0;
    
    POPSpringAnimation *fade = [POPSpringAnimation animationWithPropertyNamed:kPOPViewAlpha];
    fade.fromValue = @1;
    fade.toValue = @0;
    fade.springSpeed = 15;
    fade.springBounciness = 0;
    
    //disable user interaction since we are never removing the view we are animating out of the way from the view hierarchy
   // [self.blurView setRecursiveInteraction:NO];
    
    [self.animationStack pushAnimation:lift withTargetObject:self.blurView.layer forKey:@"lift"];
    [self.animationStack pushAnimation:fade withTargetObject:self.blurView forKey:@"fade"];
}

- (void)testScanning {
    [self scanner:self.scanning didRecieveBarcode:[GLBarcode barcodeWithBarcode:@"0012000001086"]];
}

- (void)scanner:(GLScanningSession *)scanner didRecieveBarcode:(GLBarcode *)barcode {
    [SVProgressHUD show];
    
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
    CGPoint finalConfirmationViewPosition = CGPointMake(self.view.center.x, CGRectGetHeight(self.view.frame) - CGRectGetHeight(confirmationView.frame) * 0.5);
    
    POPSpringAnimation *presentConfirmationView = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
    presentConfirmationView.fromValue = [NSValue valueWithCGPoint:confirmationView.center];
    presentConfirmationView.toValue = [NSValue valueWithCGPoint:finalConfirmationViewPosition];
    presentConfirmationView.springBounciness = [self.tweaksForConfirmAnimation[@"Spring Bounce"] floatValue];
    presentConfirmationView.springSpeed = [self.tweaksForConfirmAnimation[@"Spring Speed"] floatValue];
    
    [self.view addSubview:confirmationView];
    [self.animationStack pushAnimation:presentConfirmationView withTargetObject:confirmationView forKey:@"bounce"];
    
    self.confirmationView = confirmationView; //weak pointer so set after we add it to the subview
    
    //we can't hook the user's inputs directly to the GLBarcodeItem because that would change the database when we save it
    //instead, we hook the user's changes to a modification dicionary on the user's list item, preventing changes to other user's items
    //when the user wants his item, we get the GLBarcodeItem and apply the changes in the userModificaion dictionary
    
    [[[self.confirmationView.name.rac_textSignal distinctUntilChanged] skip:1] subscribeNext:^(NSString *value) {
        [listItem addUserModification:value forKey:@"name"];
        NSLog(@"List item's modification dict %@", listItem.userModifications);
    }];
    
    [[[self.confirmationView.brand.rac_textSignal distinctUntilChanged] skip:1] subscribeNext:^(NSString *value) {
        [listItem addUserModification:value forKey:@"brand"];
        NSLog(@"List item's modification dict %@", listItem.userModifications);
    }];
    
    [[[self.confirmationView.category.rac_textSignal distinctUntilChanged] skip:1] subscribeNext:^(NSString *value) {
        [listItem addUserModification:value forKey:@"category"];
        NSLog(@"List item's modification dict %@", listItem.userModifications);
    }];
    
    [[[self.confirmationView.manufacturer.rac_textSignal distinctUntilChanged] skip:1] subscribeNext:^(NSString *value) {
        [listItem addUserModification:value forKey:@"manufacturer"];
        NSLog(@"List item's modification dict %@", listItem.userModifications);
    }];
}

//sets up a confirmation view that tells the delegate when the user has clicked the confirm button and passes the list item to it
- (GLItemConfirmationView *)prepareConfirmationViewWithListItem:(GLListObject *)list {
    CGRect frame = self.view.frame;
    CGRect popupViewSize = CGRectMake(0, CGRectGetHeight(frame), CGRectGetWidth(frame), CGRectGetHeight(frame) * 0.5);
    
    GLItemConfirmationView *confirmationView = [[GLItemConfirmationView alloc] initWithBlurAndFrame:popupViewSize andBarcodeItem:list.item];
    
    RACSignal *canSubmitSignal = [confirmationView.name.rac_textSignal map:^id(NSString *name) {
        return @([name length] > 0);
    }];
    
    @weakify(self);
    confirmationView.confirm.rac_command = [[RACCommand alloc] initWithEnabled:canSubmitSignal signalBlock:^RACSignal *(id input) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
            [self.delegate didRecieveNewListItem:list];
            
            [[[self.animationStack popAllAnimationsWithTargetObject:self.confirmationView] flattenMap:^RACStream *(id value) {
                return [[self.animationStack popAllAnimations] doCompleted:^{
                    [self.confirmationView removeFromSuperview];
                }];
            }] subscribeCompleted:^{
                [subscriber sendCompleted];
            }];
            
            return nil;
        }];
    }];
    
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


@end
