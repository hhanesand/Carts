//
//  GLTableViewController.m
//  GroceryList
//
//  Created by Hakon Hanesand on 1/18/15.

#import <ReactiveCocoa/ReactiveCocoa.h>

#import "GLListTableViewController.h"
#import "GLTableViewCell.h"
#import "GLScannerViewController.h"
#import "GLListObject.h"
#import "GLBarcodeObject.h"

#import "PFQueryTableViewController+Caching.h"
#import "PFObject+GLPFObject.h"
#import "GLPullToCloseTransitionManager.h"
#import "UIImageView+AFNetworking.h"
#import "GLListItemObject.h"
#import "RACUnit.h"
#import "PFQuery+GLQuery.h"
#import "PFUser+GLUser.h"

static NSString *const kGLTableViewReuseIdentifier = @"GLTableViewCellIdentifier";
static NSString *const kGLParsePinName = @"GLTableViewPin";

@interface GLListTableViewController ()
@property (nonatomic) GLScannerViewController *scanner;
@end

@implementation GLListTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = NO;
        self.loadingViewEnabled = NO;
        
        self.scanner = [GLScannerViewController instance];
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
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([GLTableViewCell class]) bundle:nil] forCellReuseIdentifier:kGLTableViewReuseIdentifier];
    
    [self subscribeToScannerSignal];
}

- (void)subscribeToScannerSignal {
    [[[self.scanner.listItemSignal takeUntil:self.rac_willDeallocSignal] deliverOnMainThread] subscribeNext:^(GLBarcodeObject *barcodeObject) {
        GLListItemObject *object = [self.user.list.items.rac_sequence objectPassingTest:^BOOL(GLListItemObject *object) {
            return [object.item isEqual:barcodeObject];
        }];
        
        if (object) {
            object.quantity = [NSNumber numberWithInt:[object.quantity intValue] + 1];
        } else {
            [self.user.list.items addObject:[GLListItemObject objectWithBarcodeObject:barcodeObject]];
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
    PFQuery *query = [GLListObject query];
    [query includeKey:@"items.item"];
    
    return [[query getObjectWithIdWithSignal:[PFUser currentUser].list.objectId] map:^NSArray *(GLListObject *listObject) {
        return listObject.items;
    }];
}

- (RACSignal *)cachedSignalForTable {
    PFQuery *query = [GLListObject query];
    [query includeKey:@"items.item"];
    [query fromLocalDatastore];
    
    return [[query getObjectWithIdWithSignal:[PFUser currentUser].list.objectId] map:^NSArray *(GLListObject *listObject) {
        return listObject.items;
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(GLListItemObject *)object {
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

- (void)setUser:(PFUser *)user {
    _user = user;
    self.title = [self.user bestName];
}

@end
