//
//  GLScannerViewController.m
//  GroceryList
//
//  Created by Hakon Hanesand on 2/11/15.
//
//

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <Pop/POP.h>

//#import "PFQuery.h"

#import "RACSubject.h"

#import "SVProgressHUD.h"

#import "GLScannerViewController.h"
#import "GLBarcodeManager.h"
#import "GLBingFetcher.h"
#import "GLScannerWrapperViewController.h"
#import "GLItemConfirmationView.h"
#import "GLListItem.h"
#import "GLBarcodeItem.h"
#import "UIColor+GLColor.h"
#import "POPPropertyAnimation+GLAdditions.h"
#import "GLTweakCollection.h"
#import "POPAnimationExtras.h"

#define TICK   NSDate *startTime = [NSDate date]
#define TOCK   NSLog(@"Time GLScannerViewController: %f", -[startTime timeIntervalSinceNow])

@interface GLScannerViewController()
@property (nonatomic) GLBarcodeManager *manager;
@property (nonatomic) GLBingFetcher *bing;
@property (nonatomic) GLScannerWrapperViewController *scanner;

@property (nonatomic) NSDictionary *tweaksForConfirmAnimation;
@end

static NSString *identifier = @"GLBarcodeItemTableViewCell";

@implementation GLScannerViewController

- (instancetype)init {
    if (self = [super init]) {
        self.manager = [[GLBarcodeManager alloc] init];
        self.bing = [GLBingFetcher sharedFetcher];
        self.scanner = [[GLScannerWrapperViewController alloc] init];
        self.tweaksForConfirmAnimation = @{@"Spring Speed" : @(20), @"Spring Bounce" : @(0)};
        
        [self.scanner startScanning];
        [self tweak];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillDisappear:) name:UIKeyboardWillHideNotification object:nil];
        
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)tweak {
    [GLTweakCollection defineTweakCollectionInCategory:@"Animations" collection:@"Present Confirm View" withType:GLTWeakPOPSpringAnimation andObserver:self];
}

- (void)tweakCollection:(GLTweakCollection *)collection didChangeTo:(NSDictionary *)values {
    if ([collection.name isEqualToString:@"Present Confirm View"]) {
        self.tweaksForConfirmAnimation = values;
    }
}

- (void)keyboardWillAppear:(NSNotification *)notif {
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
}

- (void)keyboardWillDisappear:(NSNotification *)notif {
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
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addContainerScannerViewControllerWrapper];
    
    [self getWindow].backgroundColor = [UIColor colorWithRed:0 green:67 blue:88];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(didPressTestButton)] animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)addContainerScannerViewControllerWrapper {
    NSLog(@"Frame %@", NSStringFromCGRect(self.view.frame));
    self.scanner.view.frame = self.view.frame;
    [self.view addSubview:self.scanner.view];
    
    [self.scanner willMoveToParentViewController:self];
    [self addChildViewController:self.scanner];
    [self.scanner didMoveToParentViewController:self];
}

#pragma mark - Scanner Delegate

- (void)didPressTestButton {
    GLBarcodeItem *item = [GLBarcodeItem object];
    item.barcodes = [NSMutableArray arrayWithObject:@"0012000001086"];
    [self scanner:nil didRecieveBarcodeItems:[NSArray arrayWithObject:item]];
}

- (void)scanner:(GLScannerWrapperViewController *)scannerContorller didRecieveBarcodeItems:(NSArray *)barcodeItems {
    TICK;
    [SVProgressHUD show];
    [[[self fetchProductNameForBarcodeItem:[barcodeItems firstObject]] logAll] subscribeNext:^(GLListItem *listItem) {
        [SVProgressHUD showSuccessWithStatus:@""];
        [self showConfirmationViewWithListItem:listItem];
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
    
    [self prepareDimmingViewWithAlphaAnimationTo:0.6 forFinalYPositionOfConfirmationView:finalConfirmationViewPosition.y];
    
    [self.view addSubview:confirmationView];
    [self.animationStack pushAnimation:presentConfirmationView withTargetObject:confirmationView forKey:@"bounce"];
    
    self.confirmationView = confirmationView; //weak pointer so set after we add it to the subview
    
    RAC(listItem.item, name) = [self.confirmationView.name.rac_textSignal logAll];
    RAC(listItem.item, category) = [self.confirmationView.category.rac_textSignal logAll];
    RAC(listItem.item, manufacturer) = [self.confirmationView.manufacturer.rac_textSignal logAll];
    RAC(listItem.item, brand) = [self.confirmationView.brand.rac_textSignal logAll];
}

- (void)prepareDimmingViewWithAlphaAnimationTo:(CGFloat)alpha forFinalYPositionOfConfirmationView:(float)pos {
    UIView *dimmingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), pos)];
    dimmingView.backgroundColor = [UIColor blackColor];
    
    POPSpringAnimation *dimmingAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewAlpha];
    dimmingAnimation.fromValue = @(0);
    dimmingAnimation.toValue = @(alpha);
    dimmingAnimation.springBounciness = [self.tweaksForConfirmAnimation[@"Spring Bounce"] floatValue];
    dimmingAnimation.springSpeed = [self.tweaksForConfirmAnimation[@"Spring Speed"] floatValue];
    
    #warning dimming view is never removed from the stack?
    [self.view addSubview:dimmingView];
    [self.animationStack pushAnimation:dimmingAnimation withTargetObject:dimmingView forKey:@"dimming"];
}

//sets up a confirmation view that tells the delegate when the user has clicked the confirm button and passes the list item to it
- (GLItemConfirmationView *)prepareConfirmationViewWithListItem:(GLListItem *)list {
    CGRect frame = self.view.frame;
    CGRect popupViewSize = CGRectMake(0, CGRectGetHeight(frame), CGRectGetWidth(frame), CGRectGetHeight(frame) * 0.5);
    
    GLItemConfirmationView *confirmationView = [[GLItemConfirmationView alloc] initWithBlurAndFrame:popupViewSize andBarcodeItem:list.item];
    
    RACSignal *canSubmitSignal = [confirmationView.name.rac_textSignal map:^id(NSString *name) {
        return @([name length] > 0);
    }];

    confirmationView.confirm.rac_command = [[RACCommand alloc] initWithEnabled:canSubmitSignal signalBlock:^RACSignal *(id input) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [self.delegate didRecieveNewListItem:list];
            
            [[[self.animationStack popAllAnimations] deliverOnMainThread] subscribeCompleted:^{
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

- (PFQuery *)generateQueryWithBarcodeItem:(GLBarcodeItem *)barcodeItem {
    PFQuery *query = [GLBarcodeItem query];
    [query whereKey:@"barcodes" containedIn:barcodeItem.barcodes];
    return query;
}

- (RACSignal *)fetchProductNameForBarcodeItem:(GLBarcodeItem *)barcodeItem {
    [SVProgressHUD show];

    RACSignal *resultSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        PFQuery *productQuery = [self generateQueryWithBarcodeItem:barcodeItem];
        GLBarcodeItem *result = (GLBarcodeItem *)[productQuery getFirstObject];
        GLListItem *list = [GLListItem objectWithCurrentUser];
        
        if (result) {
            list.item = result;
            [subscriber sendNext:list];
        } else {
            list.item = barcodeItem;
            [subscriber sendNext:[self fetchProductInformationFromFactualForListItem:list]];
        }
        
        [subscriber sendCompleted];
        return nil;
    }];
    
    return resultSignal;
}

- (RACSignal *)fetchProductInformationFromFactualForListItem:(GLListItem *)list {
    return [[[self.manager queryFactualForItem:list.item] map:^id(NSDictionary *itemInformation) {
        [list.item loadJSONData:itemInformation];
        return list;
    }] flattenMap:^RACStream *(GLListItem *item) {
        return [self.bing fetchImageURLFromBingForListItem:item];
    }];
}

- (UIView *)getTopView {
    return [self getWindow].subviews[0];
}

- (UIWindow *)getWindow {
    return [[UIApplication sharedApplication] keyWindow];
}

@end
