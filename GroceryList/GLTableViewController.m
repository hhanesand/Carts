//
//  GLTableViewController.m
//  GroceryList
//
//  Created by Hakon Hanesand on 1/18/15.
//
//

#import <ReactiveCocoa/ReactiveCocoa.h>

#import "PFQueryTableViewController+Caching.h"

#import "UIImageView+AFNetworking.h"

#import "GLTableViewController.h"
#import "GLTableViewCell.h"
#import "GLBarcodeManager.h"
#import "GLBingFetcher.h"
#import "GLScannerViewController.h"
#import "GLParseAnalytics.h"
#import "GLListItem.h"
#import "GLBarcodeItem.h"

static NSString *reuseIdentifier = @"GLTableViewCell";

#define TICK   NSDate *startTime = [NSDate date]
#define TOCK   NSLog(@"Time GLTableViewController: %f", -[startTime timeIntervalSinceNow])

@interface GLTableViewController()
@property (nonatomic) GLScannerViewController *scanner;
@end

@implementation GLTableViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.parseClassName = [GLListItem parseClassName];
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = NO;
        self.loadingViewEnabled = NO;
        
        TICK;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            GLScannerViewController *s = [[GLScannerViewController alloc] init];
            s.delegate = self;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.scanner = s;
            });
        });
        TOCK;
    }
    
    return self;
}

#pragma mark - Navigation

- (IBAction)didPressScannerButton:(UIBarButtonItem *)sender {
    if (!self.scanner) {
        NSLog(@"Scanner was not loaded");
    }
    
    TICK;
    [self.navigationController pushViewController:self.scanner animated:YES];
    TOCK;
}

#pragma mark - Parse

- (PFQuery *)queryForTable {
    PFQuery *query = [GLListItem query];
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

- (void)didRecieveNewListItem:(GLListItem *)listItem {
    [listItem pinInBackgroundWithName:@"groceryList" block:^(BOOL succeeded, NSError *error) {
        [self cache_loadObjectsClear:YES];
        [listItem saveEventually];
    }];
}

@end
