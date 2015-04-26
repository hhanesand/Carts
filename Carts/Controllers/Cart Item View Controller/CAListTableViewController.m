//
//  CATableViewController.m
//  GroceryList
//
//  Created by Hakon Hanesand on 1/18/15.

#import <ReactiveCocoa/ReactiveCocoa.h>

#import "CAListTableViewController.h"
#import "CATableViewCell.h"
#import "CAScannerViewController.h"
#import "CAListObject.h"
#import "CABarcodeObject.h"

#import "PFQueryTableViewController+Caching.h"
#import "PFObject+CAPFObject.h"
#import "CAPullToCloseTransitionManager.h"
#import "UIImageView+AFNetworking.h"
#import "CAListItemObject.h"
#import "RACUnit.h"
#import "PFQuery+CAQuery.h"
#import "PFUser+CAUser.h"

static NSString *const kCATableViewReuseIdentifier = @"CATableViewCellIdentifier";
static NSString *const kCAParsePinName = @"CATableViewPin";

@interface CAListTableViewController ()
@property (nonatomic) CAScannerViewController *scanner;
@end

@implementation CAListTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = NO;
        self.loadingViewEnabled = NO;
        
        self.scanner = [CAScannerViewController instance];
        self.scanner.view.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
    }
    
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(didPressAddButton)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [self setToolbarItems:@[flexibleSpace, button, flexibleSpace]];
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([CATableViewCell class]) bundle:nil] forCellReuseIdentifier:kCATableViewReuseIdentifier];
    
    [self subscribeToScannerSignal];
}

- (void)subscribeToScannerSignal {
    [[[self.scanner.listItemSignal takeUntil:self.rac_willDeallocSignal] deliverOnMainThread] subscribeNext:^(CABarcodeObject *barcodeObject) {
        CAListItemObject *object = [self.user.list.items.rac_sequence objectPassingTest:^BOOL(CAListItemObject *object) {
            return [object.item isEqual:barcodeObject];
        }];
        
        if (object) {
            object.quantity = [NSNumber numberWithInt:[object.quantity intValue] + 1];
        } else {
            [self.user.list.items addObject:[CAListItemObject objectWithBarcodeObject:barcodeObject]];
        }
        
        [[self.user pinWithSignal] subscribeCompleted:^{
            [self.user saveInBackground];
            [self loadObjects];
        }];
    }];
}

- (void)didPressAddButton {
    [self presentViewController:self.scanner animated:YES completion:nil];
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

#pragma mark - Parse

- (RACSignal *)signalForTable {
    PFQuery *query = [CAListObject query];
    [query includeKey:@"items.item"];
    
    return [[query getObjectWithIdWithSignal:[PFUser currentUser].list.objectId] map:^NSArray *(CAListObject *listObject) {
        return listObject.items;
    }];
}

- (RACSignal *)cachedSignalForTable {
    PFQuery *query = [CAListObject query];
    [query includeKey:@"items.item"];
    [query fromLocalDatastore];
    
    return [[query getObjectWithIdWithSignal:[PFUser currentUser].list.objectId] map:^NSArray *(CAListObject *listObject) {
        return listObject.items;
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(CAListItemObject *)object {
    CATableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCATableViewReuseIdentifier forIndexPath:indexPath];
    
    cell.name.text = object.item.name;
    cell.brand.text = object.item.brand;
    cell.category.text = object.item.category;
    
    [cell.image setImageWithURL:[NSURL URLWithString:object.item.image[0]]];
    
    return cell;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 71;
}

- (void)setUser:(PFUser *)user {
    _user = user;
    self.title = [self.user bestName];
}

@end
