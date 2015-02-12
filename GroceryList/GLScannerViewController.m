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

@interface GLScannerViewController()
@property (nonatomic, readonly) NSString *apiKey;
@property (nonatomic) GLBarcodeManager *manager;
@property (nonatomic) GLBingFetcher *bing;
@end

@implementation GLScannerViewController

#warning does this initialization structure actually work?
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
    
    [SVProgressHUD show];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[[self.manager fetchNameOfItemWithBarcode:barcode] flattenMap:^RACStream *(NSString *nameOfBarcodeItem) {
            GLBarcodeItem *barcodeItem = [GLBarcodeItem object];
            barcodeItem.name = nameOfBarcodeItem;
            
            [SVProgressHUD showSuccessWithStatus:@"Much Success!"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate didReceiveNewBarcodeItem:barcodeItem];
                [self.navigationController popViewControllerAnimated:YES];
            });
            
            return [self.bing fetchImageURLFromBingForBarcodeItem:barcodeItem];
        }] subscribeCompleted:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate didReceiveUpdateForBarcodeItem];
            });
        }];
    });
}

@end
