//
//  GLTableViewController.m
//  GroceryList
//
//  Created by Hakon Hanesand on 1/18/15.
//
//

#import "GLTableViewController.h"
#import "GLTableViewCell.h"
#import <Parse/Parse.h>
#import "AFNetworking.h"
#import "GLBarcodeManager.h"
#import "ReactiveCocoa/ReactiveCocoa.h"
#import "AFNetworking.h"
#import "GLBingFetcher.h"

static NSString *reuseIdentifier = @"GLTableViewCell";

@interface GLTableViewController()
@property (nonatomic) NSMutableArray *barcodeItems;
@property (nonatomic) GLBarcodeManager *manager;
@property (nonatomic) ScanditSDKBarcodePicker *scanner;
@end

@implementation GLTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.barcodeItems = [NSMutableArray new];
    
    self.manager = [[GLBarcodeManager alloc] init];
    
    [self.manager.barcodeItemSignal subscribeNext:^(id x) {
        [self.barcodeItems addObject:x];
        [self.tableView reloadData];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableViewUpdated) name:[GLBarcodeItem notificationName] object:nil];

    [self.manager addBarcodeDatabase:[[GLBarcodeDatabase alloc] initWithURLOfDatabase:@"http://www.outpan.com/api/get-product.php?apikey=4308c0742cfa452985e8cd4d569336aa&barcode=%@" withName:@"outpan.com" andPath:@"name"]];
    
    [self.manager addBarcodeDatabase:[[GLBarcodeDatabase alloc] initWithURLOfDatabase:@"http://api.upcdatabase.org/json/938a6e05f72b4e5b7531c35374a4457d/%@"  withName:@"upcdatabase.org" andPath:@"itemname"]];
    
    [self.manager addBarcodeDatabase:[[GLBarcodeDatabase alloc] initWithURLOfDatabase:@"http://www.searchupc.com/handlers/upcsearch.ashx?request_type=3&access_token=C9D1021E-37EA-4C29-BAF0-EE92A5AB03BE&upc=%@" withName:@"searchupc.com"  andPath:@"0.productname"]];
}

- (IBAction)didTapAddGroceryBarButton:(id)sender {
    self.scanner = [[ScanditSDKBarcodePicker alloc] initWithAppKey:@"0TyjNGRpheHk1t6Ho8s6z0KJ6wQyLHv7UXs1kmm1Kx4"];
    self.scanner.overlayController.delegate = self;
    [self.scanner startScanning];
    //[self.navigationController presentViewController:scanner animated:YES completion:^{}];
    [self.navigationController pushViewController:self.scanner animated:YES];
}

#pragma mark - SCANDIT implementation

- (void)scanditSDKOverlayController:(ScanditSDKOverlayController *)overlayController didCancelWithStatus:(NSDictionary *)status {

}

- (void)scanditSDKOverlayController:(ScanditSDKOverlayController *)overlayController didManualSearch:(NSString *)text {
    
}

- (void)scanditSDKOverlayController:(ScanditSDKOverlayController *)overlayController didScanBarcode:(NSDictionary *)barcode {
    NSLog(@"Barcode receieved %@", barcode);
    [self.scanner stopScanning];
    [self.manager fetchNameOfItemWithBarcode:barcode[@"barcode"]];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)tableViewUpdated {
    NSLog(@"Updating table view %@", self.barcodeItems);
    [self.tableView reloadData];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.barcodeItems count] == 0) {
        //notify the user that there are no saved items
        UILabel *noSavedBarcodesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
        noSavedBarcodesLabel.text = @"You have not saved any barcodes.";
        noSavedBarcodesLabel.textColor = [UIColor blackColor];
        noSavedBarcodesLabel.numberOfLines = 0;
        noSavedBarcodesLabel.textAlignment = NSTextAlignmentCenter;
        noSavedBarcodesLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:15];
        [noSavedBarcodesLabel sizeToFit];
        
        self.tableView.backgroundView = noSavedBarcodesLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        return 0;
    } else {
        self.tableView.backgroundView = nil;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.barcodeItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GLTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    GLBarcodeItem *barcodeItem = self.barcodeItems[indexPath.row];
    [cell setNameOfProduct:barcodeItem.name];
    [cell setImageOfProduct:[UIImage imageWithData:barcodeItem.imageData]];
    
//    cell.rightUtilityButtons = [self rightButtons];
//    cell.delegate = self;
    
    return cell;
}

//- (NSArray *)rightButtons {
//    NSMutableArray *rightButtons = [NSMutableArray new];
//    
//    [rightButtons sw_addUtilityButtonWithColor:[UIColor colorWithRed:0.7f green:0.75f blue:0.16f alpha:1] icon:[UIImage imageNamed:@"checkmark"]];
//    
//    return rightButtons;
//}

- (void)didFinishLoadingImageForBarcodeItem:(GLBarcodeItem *)barcodeItem {
    [self.tableView reloadData];
}

- (IBAction)didPressTestButton:(id)sender {
    [self.manager fetchNameOfItemWithBarcode:@"0012000001086"];
}

@end
