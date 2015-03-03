//
//  GLScannerViewController.m
//  GroceryList
//
//  Created by Hakon Hanesand on 2/11/15.
//
//

#import <ReactiveCocoa/ReactiveCocoa.h>
#import "POPSpringAnimation.h"

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

#define TICK   NSDate *startTime = [NSDate date]
#define TOCK   NSLog(@"Time: %f", -[startTime timeIntervalSinceNow])

@interface GLScannerViewController()
@property (nonatomic) GLBarcodeManager *manager;
@property (nonatomic) GLBingFetcher *bing;
@property (nonatomic) GLScannerWrapperViewController *scanner;

//this is the current item the user has scanned
//nil if no item scanned, or if the user has confirmed an item
@property (nonatomic) GLListItem *listItem;
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
    RACSignal *barcodeInfoSignal = [self fetchProductNameForBarcodeItem:[barcodeItems firstObject]];
    
    [[barcodeInfoSignal logError] subscribeNext:^(GLListItem *list) {
        [SVProgressHUD showSuccessWithStatus:@""];
        self.listItem = list;
        [self showConfirmationView];
    }];
    
    TOCK;
}

- (void)showConfirmationView {
    GLItemConfirmationView *confirmationView = [self prepareConfirmationViewWithListItem:self.listItem];
    
    POPSpringAnimation *presentConfirmationView = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionY];
    presentConfirmationView.toValue = @(CGRectGetHeight(self.view.frame) - CGRectGetHeight(confirmationView.frame) * 0.5);
    presentConfirmationView.springBounciness = 10;
    presentConfirmationView.springSpeed = 10;
    
    [self.view addSubview:confirmationView];
    [confirmationView pop_addAnimation:presentConfirmationView forKey:@"bounce"];
}

- (GLItemConfirmationView *)prepareConfirmationViewWithListItem:(GLListItem *)list {
    CGRect frame = self.view.frame;
    CGRect popupViewSize = CGRectMake(0, CGRectGetHeight(frame), CGRectGetWidth(frame), CGRectGetHeight(frame) * 0.5);
    GLItemConfirmationView *confirmationView = [[GLItemConfirmationView alloc] initWithBlurAndFrame:popupViewSize andBarcodeItem:list.item];
    
    RACSignal *canSubmitSignal = [confirmationView.name.rac_textSignal map:^id(NSString *name) {
        return @([name length] > 0);
    }];
    
    confirmationView.cancel.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            return nil;
        }];
    }];
    
    #warning this is bad rac coding
    confirmationView.confirm.rac_command = [[RACCommand alloc] initWithEnabled:canSubmitSignal signalBlock:^RACSignal *(id input) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [self.delegate didRecieveNewListItem:self.listItem];
            [confirmationView removeFromSuperview];
            self.listItem = nil;
            return nil;
        }];
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
