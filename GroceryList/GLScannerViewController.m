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

@interface GLScannerViewController()
@property (nonatomic, readonly) NSString *apiKey;
@property (nonatomic) GLBarcodeManager *manager;
@property (nonatomic) GLBingFetcher *bing;
@end

@implementation GLScannerViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _apiKey = @"0TyjNGRpheHk1t6Ho8s6z0KJ6wQyLHv7UXs1kmm1Kx4";
        self.manager = [[GLBarcodeManager alloc] init];
        self.bing = [GLBingFetcher sharedFetcher];
        
        [self.manager addBarcodeDatabase:[[GLBarcodeDatabase alloc] initWithURLOfDatabase:@"http://www.outpan.com/api/get-product.php?apikey=4308c0742cfa452985e8cd4d569336aa&barcode=%@" withName:@"outpan.com" andPath:@"name"]];
        
        [self.manager addBarcodeDatabase:[[GLBarcodeDatabase alloc] initWithURLOfDatabase:@"http://api.upcdatabase.org/json/938a6e05f72b4e5b7531c35374a4457d/%@"  withName:@"upcdatabase.org" andPath:@"itemname"]];
        
        [self.manager addBarcodeDatabase:[[GLBarcodeDatabase alloc] initWithURLOfDatabase:@"http://www.searchupc.com/handlers/upcsearch.ashx?request_type=3&access_token=C9D1021E-37EA-4C29-BAF0-EE92A5AB03BE&upc=%@" withName:@"searchupc.com"  andPath:@"0.productname"]];
        
        return [self initWithAppKey:self.apiKey];
    }
    
    return nil;
}

- (instancetype)initWithAppKey:(NSString *)scanditSDKAppKey {
    if (self = [super initWithAppKey:scanditSDKAppKey]) {
        self.overlayController.delegate = self;
    }
    
    return self;
}

#pragma mark - Test methods

- (IBAction)didPressTestButton:(UIBarButtonItem *)sender {
    [self scanditSDKOverlayController:nil didScanBarcode:[NSDictionary dictionaryWithObject:@"0012000001086" forKey:@"barcode"]];
}

#pragma mark - SCANDIT implementation

- (void)scanditSDKOverlayController:(ScanditSDKOverlayController *)overlayController didCancelWithStatus:(NSDictionary *)status {
    
}

- (void)scanditSDKOverlayController:(ScanditSDKOverlayController *)overlayController didManualSearch:(NSString *)text {
    
}

- (void)scanditSDKOverlayController:(ScanditSDKOverlayController *)overlayController didScanBarcode:(NSDictionary *)dict {
    [self stopScanning];
    
    NSString *barcode = dict[@"barcode"];
    NSLog(@"Recieved barcode %@", barcode);
    
    [self fetchProductNameForBarcode:barcode];
}

#pragma mark - Networking

- (void)fetchProductNameForBarcode:(NSString *)barcode {
    [SVProgressHUD show];
    
    PFQuery *productQuery = [GLBarcodeItem query];
    [productQuery whereKey:@"product_name" equalTo:barcode];
    productQuery.limit = 1;
    
    [productQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count] >= 1) {
            NSLog(@"Found object in parse database %@", objects[1]);
        } else {
            NSLog(@"Could not find product info in parse about %@", barcode);
            [[GLParseAnalytics shared] trackMissingBarcode:barcode];
            [self fetchProductNameFromSecondaryDatabasesWithBarcode:barcode];
        }
    }];
}

- (void)fetchProductNameFromSecondaryDatabasesWithBarcode:(NSString *)barcode {
    [[[[[self.manager fetchNameOfItemWithBarcode:barcode] flattenMap:^RACStream *(NSString *nameOfBarcodeItem) {
        GLBarcodeItem *barcodeItem = [GLBarcodeItem object];
        barcodeItem.name = nameOfBarcodeItem;
        barcodeItem.barcode = barcode;
        
        [SVProgressHUD showSuccessWithStatus:@"Much Success!"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate didReceiveNewBarcodeItem:barcodeItem];
            [self.navigationController popViewControllerAnimated:YES];
        });
        
        return [self.bing fetchImageURLFromBingForBarcodeItem:barcodeItem];
    }] doNext:^(GLBarcodeItem *item) {
        [item saveEventually];
        item.imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:item.url]];
    }] deliverOnMainThread] subscribeCompleted:^{
        [self.delegate didReceiveUpdateForBarcodeItem];
    }];
}

@end
