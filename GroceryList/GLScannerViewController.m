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

#define TICK   NSDate *startTime = [NSDate date]
#define TOCK   NSLog(@"Time: %f", -[startTime timeIntervalSinceNow])

@interface GLScannerViewController()
@property (nonatomic) GLBarcodeManager *manager;
@property (nonatomic) GLBingFetcher *bing;
@property (nonatomic) GLScannerWrapperViewController *scanner;
@end

@implementation GLScannerViewController

- (instancetype)init {
    if (self = [super init]) {
        self.manager = [[GLBarcodeManager alloc] init];
        self.bing = [GLBingFetcher sharedFetcher];
        self.scanner = [[GLScannerWrapperViewController alloc] init];
    }
    
    return self;
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addContainerScannerViewControllerWrapper];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(didPressTestButton)] animated:YES];
    
    [self getWindow].backgroundColor = [UIColor r:0 g:67 b:88];
}

- (void)addContainerScannerViewControllerWrapper {
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
    [[[self fetchProductNameForBarcodeItem:[barcodeItems firstObject]] logAll] subscribeNext:^(GLListItem *listItem) {
        [SVProgressHUD showSuccessWithStatus:@""];
        [self showConfirmationViewWithListItem:listItem];
        [self scaleAndFadeBackgroundViewWithShrink:0.85];
    }];
    TOCK;
}

- (UIView *)getTopView {
    return [self getWindow].subviews[0];
}

- (UIWindow *)getWindow {
    return [[UIApplication sharedApplication] keyWindow];
}

//scales the background view - call again with value of 1 for scale to undo effects
//returns a signal that sends a message when the animation is done
- (RACSignal *)scaleAndFadeBackgroundViewWithShrink:(CGFloat)scale {
    UIView *topView = [self getTopView];
    BOOL isShrinking = scale < 1;
    RACSubject *finishSignal = [RACSubject subject];
    
    POPSpringAnimation *scaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    scaleAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(1, 1)];
    scaleAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(scale, scale)];
    scaleAnimation.springBounciness = 16;
    scaleAnimation.springSpeed = 20;
    
    //consider adding a category for this
    scaleAnimation.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        if (finished) {
            [finishSignal sendCompleted];
        }
    };
    
    [self.animationStack pushAnimation:scaleAnimation withTargetObject:topView forKey:@"scale"];
    
    POPSpringAnimation *opacityAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewAlpha];
    opacityAnimation.toValue = isShrinking ? @(0.75) : @(1);
    opacityAnimation.springBounciness = 16;
    opacityAnimation.springSpeed = 20;
    
    [self.animationStack pushAnimation:opacityAnimation withTargetObject:topView forKey:@"alpha"];
    
    return finishSignal;
}

//preparse confirmation view and add animation
- (void)showConfirmationViewWithListItem:(GLListItem *)listItem {
    [self scaleAndFadeBackgroundViewWithShrink:0.85];
     
    GLItemConfirmationView *confirmationView = [self prepareConfirmationViewWithListItem:listItem];
    
    POPSpringAnimation *presentConfirmationView = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
    presentConfirmationView.toValue = [NSValue valueWithCGPoint:CGPointMake(self.view.center.x, CGRectGetHeight(self.view.frame) - CGRectGetHeight(confirmationView.frame) * 0.5)];
    presentConfirmationView.springBounciness = 16;
    presentConfirmationView.springSpeed = 16;
    
    [[self getWindow] addSubview:confirmationView];
    [confirmationView pop_addAnimation:presentConfirmationView forKey:@"bounce"];
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
            [subscriber sendCompleted];
            
            [[self scaleAndFadeBackgroundViewWithShrink:1.0] subscribeCompleted:^{
                [confirmationView removeFromSuperview];
                [self.navigationController popViewControllerAnimated:YES];
            }];
            
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

@end
