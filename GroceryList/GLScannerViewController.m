//
//  GLScannerViewController.m
//  GroceryList
//
//  Created by Hakon Hanesand on 2/11/15.
//
//

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
@property (weak, nonatomic) IBOutlet UIView *containerView;
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

- (void)awakeFromNib {
    self.scanner.view.bounds = self.containerView.bounds;
    [self addChildViewController:self.scanner];
    [self.containerView addSubview:self.scanner.view];
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
    NSLog(@"Recieved %lu barcode items.", (unsigned long)[barcodeItems count]);
    
    for (GLBarcodeItem *barcodeItem in barcodeItems) {
        TICK;
        [self fetchProductNameForBarcodeItem:barcodeItem];
        TOCK;
    }
}

- (void)animate {
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [blurEffectView setFrame:self.view.bounds];
    [self.scanner.view addSubview:blurEffectView];
    
    CGRect bounds = self.view.bounds;
    GLItemConfirmationView *view = [[GLItemConfirmationView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(bounds), CGRectGetWidth(bounds), CGRectGetHeight(bounds) * 0.65)];

    //animate view from bottom of screen to some point in the middle
    POPSpringAnimation *bounce = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionY];
    bounce.toValue = @(CGRectGetHeight(bounds) - CGRectGetHeight(view.bounds) * 0.5 + 30);
    bounce.springBounciness = 10;
    
    bounce.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        NSLog(@"Animation has finished");
    };
    
    NSLog(@"Bounds %@", NSStringFromCGRect(view.frame));
    
    [blurEffectView addSubview:view];
    [view pop_addAnimation:bounce forKey:@"bounce"];
}

#pragma mark - Networking

- (PFQuery *)generateQueryWithBarcodeItem:(GLBarcodeItem *)barcodeItem {
    PFQuery *query = [GLBarcodeItem query];
    [query whereKey:@"barcodes" containedIn:barcodeItem.barcodes];
    return query;
}

- (void)fetchProductNameForBarcodeItem:(GLBarcodeItem *)barcodeItem {
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
