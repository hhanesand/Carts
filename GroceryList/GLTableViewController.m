//
//  GLTableViewController.m
//  GroceryList
//
//  Created by Hakon Hanesand on 1/18/15.
//
//

#import "GLTableViewController.h"
#import "GLTableViewCell.h"


static NSString *reuseIdentifier = @"GLTableViewCell";

@interface GLTableViewController()
@end

@implementation GLTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (IBAction)didTapAddGroceryBarButton:(id)sender {
    ZBarReaderViewController *barcodeViewController = [ZBarReaderViewController new];
    barcodeViewController.readerDelegate = self;
    barcodeViewController.supportedOrientationsMask = ZBarOrientationMaskAll;

    ZBarImageScanner *scanner = barcodeViewController.scanner;
    [scanner setSymbology:ZBAR_I25 config:ZBAR_CFG_ENABLE to:0];
    
    barcodeViewController.navigationItem.title = @"Scan Barcode";
    [self.navigationController pushViewController:barcodeViewController animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GLTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    cell.label.text = @"HEYTHERE";
    
    return cell;
}

@end
