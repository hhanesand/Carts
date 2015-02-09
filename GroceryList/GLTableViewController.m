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

#define GLMakeRange(a, b) NSMakeRange(a, b - (a))
#define ObserveArray(TARGET, KEYPATH) [self rac_valuesAndChangesForKeyPath:@keypath(TARGET, KEYPATH) options:NSKeyValueObservingOptionNew observer:nil]

@interface GLTableViewController()
@property (nonatomic) NSMutableArray *barcodes;
@property (nonatomic) NSMutableArray *images;
@property (nonatomic) NSMutableArray *names;

@property (nonatomic) GLBarcodeManager *manager;
@property (nonatomic) NSMutableArray *tempNames;
@end

@implementation GLTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.barcodes = [NSMutableArray new];
    self.images = [NSMutableArray new];
    self.names = [NSMutableArray new];
    self.tempNames = [NSMutableArray new];
    
    self.manager = [[GLBarcodeManager alloc] init];
    
    [self.manager.receiveInternetResponseSignal subscribeNext:^(id x) {
        [self.tempNames addObject:x];
    } error:^(NSError *error) {
        NSLog(@"Error during net request : %@", error);
    } completed:^{
        [self didGetNamesFromServers];
    }];

    [self.manager addBarcodeDatabase:[[GLBarcodeDatabase alloc] initWithNameOfDatabase:@"http://www.outpan.com/api/get-product.php?apikey=4308c0742cfa452985e8cd4d569336aa&barcode=%@" withReturnType:GLBarcodeDatabaseJSON andPath:@"name"]];
    
    [self.manager addBarcodeDatabase:[[GLBarcodeDatabase alloc] initWithNameOfDatabase:@"http://upcdatabase.idb.s1.jcink.com/upc.php?act=lookup&upc=%@" withReturnType:GLBarcodeDatabaseHTLM andPath:@"body > center:nth-child(1) > table > tbody > tr:nth-child(4) > td:nth-child(3)"]];
    
    [self.manager addBarcodeDatabase:[[GLBarcodeDatabase alloc] initWithNameOfDatabase:@"http://upcmachine.com/search/list?commit=Go%2521&country=2&query=%@" withReturnType:GLBarcodeDatabaseHTLM andPath:@"#main > div.right_side > table > tbody > tr:nth-child(1) > td > table > tbody > tr:nth-child(2) > td:nth-child(2)"]];
    
    [self.manager addBarcodeDatabase:[[GLBarcodeDatabase alloc] initWithNameOfDatabase:@"http://www.compariola.com/?barcode=%@" withReturnType:GLBarcodeDatabaseHTLM andPath:@"#headerTxt>h1"]];
    
    [self.names addObject:@"Test Item"];
    [self.images addObject:[UIImage imageNamed:@"testImage"]];
    [self.barcodes addObject:@"00000000"];
    
    [self.names addObject:@"Test Item2"];
    [self.images addObject:[UIImage imageNamed:@"testImage"]];
    [self.barcodes addObject:@"000000001"];
    
    NSLog(@"STarting parse synch");
    
    PFObject *barcodeItem = [PFObject objectWithClassName:@"BarcodeItem"];
    barcodeItem[@"name"] = @"water bottle";
    barcodeItem[@"barcode"] = [self.barcodes lastObject];
    [barcodeItem save];
    
    NSLog(@"End parse synch");
    
    //[self.tableView setSeparatorInset:UIEdgeInsetsZero];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)didTapAddGroceryBarButton:(id)sender {
    ZBarReaderViewController *barcodeViewController = [ZBarReaderViewController new];
    barcodeViewController.readerDelegate = self;
    barcodeViewController.supportedOrientationsMask = ZBarOrientationMaskAll;

    [barcodeViewController.scanner setSymbology:ZBAR_I25 config:ZBAR_CFG_ENABLE to:0];
    barcodeViewController.showsCameraControls = NO;
    barcodeViewController.showsZBarControls = NO;
    
    barcodeViewController.navigationItem.title = @"Scan Barcode";
    [self.navigationController pushViewController:barcodeViewController animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
    
    if ([self.barcodes count] == 0) {
        //notify the user that there are no saved items
        UILabel *noSavedBarcodesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
        noSavedBarcodesLabel.text = @"You have not saved any barcodes.";
        noSavedBarcodesLabel.textColor = [UIColor blackColor];
        noSavedBarcodesLabel.numberOfLines = 0;
        noSavedBarcodesLabel.textAlignment = NSTextAlignmentCenter;
        noSavedBarcodesLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:15];
        [noSavedBarcodesLabel sizeToFit];
        
        self.tableView.backgroundView = noSavedBarcodesLabel;
        //self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        return 0;
    } else {
        self.tableView.backgroundView = nil;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.barcodes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GLTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    [cell setNameOfProduct:self.barcodes[indexPath.row]];
    
    if (indexPath.row < [self.images count]) {
        [cell setImageOfProduct:self.images[indexPath.row]];
    }
    
    cell.separatorInset = UIEdgeInsetsZero;
    
//    UIImageView *imageView = (UIImageView *)[cell viewWithTag:100];
//    imageView.image = self.images[indexPath.row];
    
    return cell;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self.navigationController popViewControllerAnimated:YES];
    
    id<NSFastEnumeration> results = [info objectForKey:ZBarReaderControllerResults];
    
    NSString *data;
    
    for (ZBarSymbol *symbol in results)
    {
        data = [NSString stringWithFormat:@"%@", symbol.data];
    }

    NSLog(@"%@", [data description]);
    
    [self.manager fetchNameOfItemWithBarcode:data]; //returns values on signal receiveInternetResponseSignal
}

- (IBAction)didPressTestButton:(id)sender {
    [self.manager fetchNameOfItemWithBarcode:@"0012000001086"];
}

//Called after database fetching complete. Adds the best name for the item it can find by analyzing the occurences of words in the strings.





@end
