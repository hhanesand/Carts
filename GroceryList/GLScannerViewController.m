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

@property (nonatomic) GLItemConfirmationView *confirmationView;

@property (nonatomic) RACSignal *canSubmitSignal;
@property (nonatomic) RACSignal *confirmSignal;
@property (nonatomic) RACSignal *cancelSignal;
@end

@implementation GLScannerViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.manager = [[GLBarcodeManager alloc] init];
        self.bing = [GLBingFetcher sharedFetcher];
        self.scanner = [[GLScannerWrapperViewController alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad {
    self.scanner.view.frame = self.view.frame;
    [self.scanner willMoveToParentViewController:self];
    [self addChildViewController:self.scanner];
    [self.scanner didMoveToParentViewController:self];
    [self.view addSubview:self.scanner.view];
}

#pragma mark - Lifecycle

#pragma mark - Test methods

#pragma mark - Scanner Delegate

- (IBAction)didPressTestButton:(id)sender {
    GLBarcodeItem *item = [GLBarcodeItem object];
    item.barcodes = [NSMutableArray arrayWithObject:@"0012000001086"];
    [self scanner:nil didRecieveBarcodeItems:[NSArray arrayWithObject:item]];
}

- (void)scanner:(GLScannerWrapperViewController *)scannerContorller didRecieveBarcodeItems:(NSArray *)barcodeItems {
    TICK;
    [self fetchProductNameForBarcodeItem:[barcodeItems firstObject]];
    TOCK;
    [self animate];
}

- (void)animate {
    CGRect frame = self.view.frame;
    CGRect popupViewSize = CGRectMake(0, CGRectGetHeight(frame), CGRectGetWidth(frame), CGRectGetHeight(frame) * 0.5);
    self.confirmationView = [[GLItemConfirmationView alloc] initWithBlurAndFrame:popupViewSize];
    
    self.confirmationView.cancel.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        NSLog(@"Type of input cancel %@", NSStringFromClass([input class]));
        return self.cancelSignal;
    }];
    
    self.confirmationView.confirm.rac_command = [[RACCommand alloc] initWithEnabled:self.canSubmitSignal signalBlock:^RACSignal *(id input) {
        NSLog(@"Type of input confirm %@", NSStringFromClass([input class]));
        return self.confirmSignal;
    }];

    //animate view from bottom of screen to some point in the middle
    POPSpringAnimation *bounce = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionY];
    bounce.toValue = @(CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.confirmationView.frame) * 0.5);
    bounce.springBounciness = 10;
    bounce.springSpeed = 10;
    
    [self.view addSubview:self.confirmationView];
    [self.confirmationView pop_addAnimation:bounce forKey:@"bounce"];
}

- (RACSignal *)canSubmitSignal {
    if (!_canSubmitSignal) {
        _canSubmitSignal = [_confirmationView.name.rac_textSignal map:^id(NSString *name) {
            return @([name length] > 0);
        }];
    }
    
    return _canSubmitSignal;
}

- (RACSignal *)confirmSignal {
    if (!_confirmSignal) {
        
    }
    
    return _confirmSignal;
}

- (RACSignal *)cancelSignal {
    if (!_cancelSignal) {
        
    }
    
    return _cancelSignal;
}

#pragma mark - Networking

- (PFQuery *)generateQueryWithBarcodeItem:(GLBarcodeItem *)barcodeItem {
    PFQuery *query = [GLBarcodeItem query];
    [query whereKey:@"barcodes" containedIn:barcodeItem.barcodes];
    return query;
}

- (RACSignal *)fetchProductNameForBarcodeItem:(GLBarcodeItem *)barcodeItem {
    [SVProgressHUD show];
    
    PFQuery *productQuery = [self generateQueryWithBarcodeItem:barcodeItem];
    
    [productQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        GLBarcodeItem *result = (GLBarcodeItem *)object;
        GLListItem *list = [GLListItem objectWithCurrentUser];
        RACSignal *resultSignal;
        
        if (result) {
            list.item = result;
            resultSignal = [self pinAndNotifyDelegateWithList:list isNew:YES];
        } else {
            result = barcodeItem;
            list.item = result;
            resultSignal = [self fetchProductInformationFromFactualForListItem:list];
        }
        
        //not really needed - if I do remove it, make sure to subscribe somewhere else
        [resultSignal subscribeNext:^(id x) {
            NSLog(@"Showing success");
            [SVProgressHUD showSuccessWithStatus:@"Much Success!"];
        } error:^(NSError *error) {
            NSLog(@"Error fetching data for barcode");
            //save for later attempt?
            [SVProgressHUD showErrorWithStatus:@"Such loss..."];
        }];
    }];
}

- (RACSignal *)fetchProductInformationFromFactualForListItem:(GLListItem *)list {
    return [[[[self.manager queryFactualForItem:list.item] map:^id(NSDictionary *itemInformation) {
        [list.item loadJSONData:itemInformation];
        [self pinAndNotifyDelegateWithList:list isNew:YES];
        return list;
    }] flattenMap:^RACStream *(GLListItem *item) {
        return [self.bing fetchImageURLFromBingForListItem:item];
    }] flattenMap:^RACStream *(GLListItem *item) {
        return [self pinAndNotifyDelegateWithList:list isNew:NO];
    }];
}

- (RACSignal *)pinAndNotifyDelegateWithList:(GLListItem *)list isNew:(BOOL)new {
    RACSubject *subject = [RACSubject subject];
    [list pinInBackgroundWithName:@"groceryList" block:^(BOOL succeeded, NSError *error) {
        if (new) {
            [self.delegate didReceiveNewBarcodeItem];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self.delegate didReceiveUpdateForBarcodeItem];
        }

        [subject sendNext:list];
        [subject sendCompleted];
        [list saveEventually];
    }];
    
    return subject;
}

@end
