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

#define TICK   NSDate *startTime = [NSDate date]
#define TOCK   NSLog(@"Time: %f", -[startTime timeIntervalSinceNow])

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

- (IBAction)didPressTestButton:(UIBarButtonItem *)sender {//0012000001086
    [self scanditSDKOverlayController:nil didScanBarcode:@{@"barcode" : @"0012000001086"}];
}

#pragma mark - SCANDIT implementation

- (void)scanditSDKOverlayController:(ScanditSDKOverlayController *)overlayController didCancelWithStatus:(NSDictionary *)status {
    
}

- (void)scanditSDKOverlayController:(ScanditSDKOverlayController *)overlayController didManualSearch:(NSString *)text {
    
}

- (void)scanditSDKOverlayController:(ScanditSDKOverlayController *)overlayController didScanBarcode:(NSDictionary *)dict {
    [self stopScanning];
    
    [[GLParseAnalytics shared] testCloudFunction];
    
    NSString *barcode = dict[@"barcode"];
    NSLog(@"Recieved barcode %@", barcode);
    
    [self fetchProductNameForBarcode:barcode];
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
