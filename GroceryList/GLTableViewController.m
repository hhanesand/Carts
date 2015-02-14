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
#import "GLScannerViewController.h"
#import "UIImageView+AFNetworking.h"

static NSString *reuseIdentifier = @"GLTableViewCell";

@interface GLTableViewController()
@property (nonatomic) NSMutableArray *barcodeItems;
@end

@implementation GLTableViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    NSLog(@"Init with coder");
    
    if (self = [super initWithCoder:aDecoder]) {
        self.parseClassName = @"barcodeItem";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.objectsPerPage = 5;
    }
    
    return self;
}

#pragma mark - Parse

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
}

- (void)objectsWillLoad {
    [super objectsWillLoad];
}

- (PFQuery *)queryForTable {
    PFQuery *query = [GLBarcodeItem query];
    [query orderByAscending:@"name"];
    return query;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(GLBarcodeItem *)object {
    NSLog(@"Running update");
    GLTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    cell.productName.text = object.name;
    
    //no reactive cocoa for this one...
    __weak GLTableViewCell *weakCell = cell;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:object.url]];
    UIImage *image = [UIImage imageNamed:@"document"];
    
    [cell.productImage setImageWithURLRequest:request placeholderImage:image success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        weakCell.productImage.image = image;
        [weakCell setNeedsLayout];
    } failure:nil];
    
    return cell;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.barcodeItems = [NSMutableArray new];
}

#pragma mark - Tableview data source

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

#pragma mark - GLBarcodeItemDelegate

- (void)didReceiveNewBarcodeItem:(GLBarcodeItem *)barcodeItem {
    [self.barcodeItems addObject:barcodeItem];
    [self didReceiveUpdateForBarcodeItem];
}

- (void)didReceiveUpdateForBarcodeItem {
    [self.tableView reloadData];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showScannerViewController"]) {
        GLScannerViewController *scannerController = segue.destinationViewController;
        scannerController.delegate = self;
        [scannerController startScanning];
    }
}

@end
