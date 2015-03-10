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
#import "GLListItem.h"
#import "GLBarcodeItem.h"
#import "UIColor+GLColor.h"
#import "POPPropertyAnimation+GLAdditions.h"
#import "GLTweakCollection.h"
#import "POPAnimationExtras.h"
#import "GLTableViewController.h"
#import "GLScanningSession.h"
#import "PFQuery+GLQuery.h"
#import "GLBarcode.h"

#define TICK   NSDate *startTime = [NSDate date]
#define TOCK   NSLog(@"Time GLScannerViewController: %f", -[startTime timeIntervalSinceNow])

@interface GLScannerViewController()
@property (nonatomic) GLBarcodeManager *manager;
@property (nonatomic) GLBingFetcher *bing;
@property (nonatomic) GLTableViewController *tableViewController;
@property (nonatomic) GLScanningSession *scanning;
@property (nonatomic) NSDictionary *tweaksForConfirmAnimation;
@property (nonatomic) UIVisualEffectView *blurView;
@end

static NSString *identifier = @"GLBarcodeItemTableViewCell";

@implementation GLScannerViewController

- (instancetype)init {
    if (self = [super init]) {
        self.manager = [[GLBarcodeManager alloc] init];
        self.bing = [GLBingFetcher sharedFetcher];
        self.scanning = [GLScanningSession session];
        
        [self rac];
        [self tweak];
    }
    
    return self;
}

#pragma mark - Lifecycle

- (void)loadView {
    [super loadView];
    
    self.scanning.previewLayer.frame = self.view.frame;
    self.scanning.delegate = self;
    [self.view.layer addSublayer:self.scanning.previewLayer];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didPressTestButton)]];
    
//    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
//    self.blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
//    self.blurView.frame = self.view.frame;
//    [self.view addSubview:self.blurView];
//    
//    self.tableViewController = [[GLTableViewController alloc] initWithStyle:UITableViewStylePlain];
//    self.tableViewController.view.frame = self.view.frame;
//    
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self.tableViewController];
//    [nav.navigationBar setBackgroundImage:[UIColor imageWithColor:[UIColor colorWithRed:0.002 green:1.000 blue:0.120 alpha:0.230]] forBarMetrics:UIBarMetricsDefault];
//    self.tableViewController.title = @"Grocery List";
//    
//    [[self.blurView contentView] addSubview:nav.view];
//    [self moveToViewController:nav];
    
    [self subscribeToSignals];
}

- (void)subscribeToSignals {
    @weakify(self);
    [self.tableViewController.addItemSignal subscribeNext:^(id x) {
        @strongify(self);
        
        POPSpringAnimation *alpha = [POPSpringAnimation animationWithPropertyNamed:kPOPViewAlpha];
        alpha.springSpeed = 10;
        alpha.springBounciness = 1;
        alpha.fromValue = @(1.0);
        alpha.toValue = @(0.0);
        
        POPSpringAnimation *lift = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
        lift.springSpeed = 10;
        lift.springBounciness = 1;
        lift.fromValue = [NSValue valueWithCGPoint:CGPointMake(1, 1)];
        lift.toValue = [NSValue valueWithCGPoint:CGPointMake(2, 2)];
        
        [self.blurView pop_addAnimation:alpha forKey:@"fade"];
        [self.blurView pop_addAnimation:lift forKey:@"lift"];
    }];
}

- (void)moveToViewController:(UIViewController *)viewController {
    [self addChildViewController:viewController];
    [viewController didMoveToParentViewController:self];
}

#pragma mark - Scanner Delegate

- (void)didPressTestButton {
    [self scanner:nil didRecieveBarcode:[GLBarcode barcodeWithBarcode:@"0012000001086"]];
}

- (void)scanner:(GLScanningSession *)scanner didRecieveBarcode:(GLBarcode *)barcode {
    [scanner stopScanning];
    
    TICK;
    
    [SVProgressHUD show];
    
    @weakify(self);
    [[[[[self fetchProductInformationForBarcode:barcode] deliverOnMainThread] doNext:^(id x) {
        //show success before we catch for the failure so user can tell his item info was found
        [SVProgressHUD showSuccessWithStatus:@"Item found!"];
    }] catch:^RACSignal *(NSError *error) {
        //neither parse nor factual have any information (or net error) about this item so we'll make an empty one for user to fill out
        [SVProgressHUD showErrorWithStatus:@"Item not found"];
        return [RACSignal return:[GLListItem objectWithCurrentUser]];
    }] subscribeNext:^(GLListItem *newListItem) {
        @strongify(self);
        [self showConfirmationViewWithListItem:newListItem];
    }];
    
    TOCK;
}

//prepare confirmation view and add background scale + opacity animation and the custom present animation
- (void)showConfirmationViewWithListItem:(GLListItem *)listItem {
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
    
    
    
    
    RAC(listItem.item, name) = [self.confirmationView.name.rac_textSignal logAll];
    RAC(listItem.item, category) = [self.confirmationView.category.rac_textSignal logAll];
    RAC(listItem.item, manufacturer) = [self.confirmationView.manufacturer.rac_textSignal logAll];
    RAC(listItem.item, brand) = [self.confirmationView.brand.rac_textSignal logAll];
}

//sets up a confirmation view that tells the delegate when the user has clicked the confirm button and passes the list item to it
- (GLItemConfirmationView *)prepareConfirmationViewWithListItem:(GLListItem *)list {
    CGRect frame = self.view.frame;
    CGRect popupViewSize = CGRectMake(0, CGRectGetHeight(frame), CGRectGetWidth(frame), CGRectGetHeight(frame) * 0.5);
    
    GLItemConfirmationView *confirmationView = [[GLItemConfirmationView alloc] initWithBlurAndFrame:popupViewSize andBarcodeItem:list.item];
    
    RACSignal *canSubmitSignal = [confirmationView.name.rac_textSignal map:^id(NSString *name) {
        return @([name length] > 0);
    }];

    @weakify(self, confirmationView);
    confirmationView.confirm.rac_command = [[RACCommand alloc] initWithEnabled:canSubmitSignal signalBlock:^RACSignal *(id input) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
            [self.delegate didRecieveNewListItem:list];
            
            @weakify(self);
            [[[self.animationStack popAllAnimations] deliverOnMainThread] subscribeCompleted:^{
                @strongify(self, confirmationView);
                NSLog(@"Completed");
                [confirmationView removeFromSuperview];
                [self.navigationController popViewControllerAnimated:YES];
            }];
            
            [subscriber sendCompleted];
            
            return nil;
        }];
    }];
    
    confirmationView.cancel.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [RACSignal error:[NSError errorWithDomain:@"groceryList" code:10 userInfo:@{@"reason" : @"User clicked cancel button"}]];
    }];
    
    return confirmationView;
}

#pragma mark - Networking

- (PFQuery *)queryForBarcode:(GLBarcode *)item {
    PFQuery *query = [GLBarcodeItem query];
    [query whereKey:@"barcodes" equalTo:item.barcode];
    return query;
}

- (RACSignal *)fetchProductInformationForBarcode:(GLBarcode *)barcode {
    PFQuery *productQuery = [self queryForBarcode:barcode];
    
    @weakify(self);
    return [[[productQuery getFirstObjectWithRACSignal] catch:^RACSignal *(NSError *error) {
        @strongify(self);
        
        //parse does not have this object so we'll ask factual
        return [self fetchProductInformationFromFactualForBarcode:barcode];
    }] map:^GLListItem *(GLBarcodeItem *value) {
        return [GLListItem objectWithCurrentUserAndBarcodeItem:value];
    }];
}

- (RACSignal *)fetchProductInformationFromFactualForBarcode:(GLBarcode *)barcode {
    return [[self.manager queryFactualForBarcode:barcode.barcode] map:^id(NSDictionary *itemInformation) {
        return [RACSignal return:[GLListItem objectWithCurrentUserAndBarcodeItem:[GLBarcodeItem objectWithBarcode:barcode]]];
    }];
    //TODO : reimplement image loading
}

- (UIView *)getTopView {
    return [self getWindow].subviews[0];
}

- (UIWindow *)getWindow {
    return [[UIApplication sharedApplication] keyWindow];
}

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

@end
