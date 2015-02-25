//
//  GLScannerViewController.m
//  GroceryList
//
//  Created by Hakon Hanesand on 2/11/15.
//
//

#import <Parse/Parse.h>
#import "GLScannerViewController.h"
#import "ScanditSDKOverlayController.h"
#import "SVProgressHUD.h"
#import "GLBarcodeManager.h"
#import "GLBarcodeItem.h"
#import "GLBingFetcher.h"
#import "GLParseAnalytics.h"
#import "GLListItem.h"
#import "BFTask.h"
#import <pop/POP.h>
#import "GLItemConfirmationView.h"

#define TICK   NSDate *startTime = [NSDate date]
#define TOCK   NSLog(@"Time: %f", -[startTime timeIntervalSinceNow])

@interface GLScannerViewController()
@property (nonatomic, readonly) NSString *apiKey;
@property (nonatomic) GLBarcodeManager *manager;
@property (nonatomic) GLBingFetcher *bing;
@property (nonatomic, weak) ScanditSDKBarcodePicker *scanner;
@end

@implementation GLScannerViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    NSLog(@"init with coder");
    
    if (self = [super initWithCoder:aDecoder]) {
        _apiKey = @"0TyjNGRpheHk1t6Ho8s6z0KJ6wQyLHv7UXs1kmm1Kx4";
        self.manager = [[GLBarcodeManager alloc] init];
        self.bing = [GLBingFetcher sharedFetcher];
    }
    
    return self;
}

//- (void)awakeFromNib {
//    self.scanner = [[ScanditSDKBarcodePicker alloc] initWithAppKey:self.apiKey];
//    [self.view addSubview:self.scanner.view];
//}

- (void)setScanningView:(ScanditSDKBarcodePicker *)scanner {
    self.scanner = scanner;
    scanner.overlayController.delegate = self;
    [self.view addSubview:scanner.view];
}

#pragma mark - Lifecycle

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"View will appear");
    [self.scanner startScanning];
}

- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"View will dissapear");
    [self.scanner stopScanningAndFreeze];
}

#pragma mark - Test methods

- (void)didPressTestButton {//0012000001086
    [self scanditSDKOverlayController:nil didScanBarcode:@{@"barcode" : @"0012000001086"}];
}

#pragma mark - SCANDIT implementation

- (void)scanditSDKOverlayController:(ScanditSDKOverlayController *)overlayController didCancelWithStatus:(NSDictionary *)status {
    
}

- (void)scanditSDKOverlayController:(ScanditSDKOverlayController *)overlayController didManualSearch:(NSString *)text {
    
}

- (void)scanditSDKOverlayController:(ScanditSDKOverlayController *)overlayController didScanBarcode:(NSDictionary *)dict {
    //[self stopScanning];
    
    [self animate];
    
    //[[GLParseAnalytics shared] testCloudFunction];
    
    NSString *barcode = dict[@"barcode"];
    NSLog(@"Recieved barcode %@", barcode);
    
    //[self fetchProductNameForBarcode:barcode];
}

- (void)animate {
    GLItemConfirmationView *view = [[GLItemConfirmationView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:view];
    
    //animate view from bottom of screen to some point in the middle
    POPSpringAnimation *bounce = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPosition];
    bounce.toValue = [NSValue valueWithCGPoint:CGPointMake(CGRectGetWidth(self.view.bounds) / 2, CGRectGetHeight(self.view.bounds) - view.bounds.size.height / 2)];
    
    bounce.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        NSLog(@"Animation has finished");
    };
    
    [view.layer pop_addAnimation:bounce forKey:@"bounce"];
}

#pragma mark - Networking

- (PFQuery *)generateCompoundQuery {
    PFQuery *upcQuery = [GLBarcodeItem query];
    PFQuery *upc_eQuery = [GLBarcodeItem query];
    PFQuery *ean13Query = [GLBarcodeItem query];
    
    return [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:upc_eQuery, upcQuery, ean13Query, nil]];
}

- (void)fetchProductNameForBarcode:(NSString *)barcode {
    [SVProgressHUD show];
    
    PFQuery *productQuery = [self generateCompoundQuery];
    
    [productQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        GLBarcodeItem *result = (GLBarcodeItem *)object;
        GLListItem *list = [GLListItem objectWithCurrentUser];
        RACSignal *resultSignal;
        
        if (result) {
            list.item = result;
            resultSignal = [self pinAndNotifyDelegateWithList:list isNew:YES];
        } else {
            result = [GLBarcodeItem object];
            result.upc = barcode;
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
    return [[[[self.manager queryFactualForItemWithUPC:list.item.upc] map:^id(NSDictionary *itemInformation) {
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
