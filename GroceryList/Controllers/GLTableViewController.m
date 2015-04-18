//
//  GLTableViewController.m
//  GroceryList
//
//  Created by Hakon Hanesand on 1/18/15.

#import <ReactiveCocoa/ReactiveCocoa.h>

#import "GLTableViewController.h"
#import "GLTableViewCell.h"
#import "GLScannerViewController.h"
#import "GLListObject.h"
#import "GLBarcodeObject.h"

#import "PFQueryTableViewController+Caching.h"
#import "PFObject+GLPFObject.h"
#import "GLPullToCloseTransitionManager.h"
#import "UIImageView+AFNetworking.h"
#import "GLUser.h"

static NSString *const kGLTableViewReuseIdentifier = @"GLTableViewCellIdentifier";
static NSString *const kGLParsePinName = @"GLTableViewPin";

@interface GLTableViewController ()
@property (nonatomic) GLScannerViewController *scanner;
@end

@implementation GLTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
        self.parseClassName = [GLListObject parseClassName];
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = NO;
        self.loadingViewEnabled = NO;
        self.title = @"Grocery List";
        

        self.scanner = [[GLScannerViewController alloc] init];
        self.scanner.view.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
  
    }
    
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(didPressAddButton)];
    UIBarButtonItem *share = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(didPressShareButton)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [self setToolbarItems:[NSArray arrayWithObjects:flexibleSpace, share, flexibleSpace, button, flexibleSpace, nil]];
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([GLTableViewCell class]) bundle:nil] forCellReuseIdentifier:kGLTableViewReuseIdentifier];
    
    [self subscribeToScannerSignal];
}

- (void)subscribeToScannerSignal {
    [[[self.scanner.listItemSignal takeUntil:self.rac_willDeallocSignal] deliverOnMainThread] subscribeNext:^(GLListObject *listObject) {
        [[listObject pinWithSignal] subscribeCompleted:^{
            [listObject saveInBackground];
            [self loadObjects];
        }];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:YES animated:NO];
}

- (void)didPressAddButton {
    [self presentViewController:self.scanner animated:YES completion:nil];
}

- (void)didPressShareButton {
    
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

#pragma mark - Parse

- (PFQuery *)queryForTable {
    PFQuery *query = [GLListObject query];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query includeKey:@"item"];
    [query orderByAscending:@"updatedAt"];
    return query;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(GLListObject *)object {
    GLTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kGLTableViewReuseIdentifier forIndexPath:indexPath];
    
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

@end
