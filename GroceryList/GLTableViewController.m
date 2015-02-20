//
//  GLTableViewController.m
//  GroceryList
//
//  Created by Hakon Hanesand on 1/18/15.
//
//

#import <Parse/Parse.h>
#import "GLTableViewController.h"
#import "GLTableViewCell.h"
#import "AFNetworking.h"
#import "GLBarcodeManager.h"
#import "ReactiveCocoa/ReactiveCocoa.h"
#import "AFNetworking.h"
#import "GLBingFetcher.h"
#import "GLScannerViewController.h"
#import "UIImageView+AFNetworking.h"
#import "PFQueryTableViewController+Caching.h"
#import "GLParseAnalytics.h"

static NSString *reuseIdentifier = @"GLTableViewCell";

@implementation GLTableViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.parseClassName = @"barcodeItem";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = NO;
        self.loadingViewEnabled = NO;
    }
    
    return self;
}

#pragma mark - Parse

- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:@"list"];
    [query whereKey:@"owner" equalTo:[PFUser currentUser]];
    [query includeKey:@"item"];
    [query orderByAscending:@"updatedAt"];
    return query;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    GLTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    GLBarcodeItem *item = object[@"item"];
    
    cell.productName.text = item.name;
    
    //no reactive cocoa for this one...
    __weak GLTableViewCell *weakCell = cell;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:item.image[0]]];
    UIImage *image = [UIImage imageNamed:@"document"];
    
    [cell.productImage setImageWithURLRequest:request placeholderImage:image success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        weakCell.productImage.image = image;
        [weakCell setNeedsLayout];
    } failure:nil];
    
    return cell;
}

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    [self cache_init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setToolbarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setToolbarHidden:YES animated:YES];
}


#pragma mark - Tableview data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.objects count] == 0) {
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

#pragma mark - GLBarcodeItemDelegate

- (void)didReceiveNewBarcodeItem {
    [self cache_loadObjectsClear:YES];
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
