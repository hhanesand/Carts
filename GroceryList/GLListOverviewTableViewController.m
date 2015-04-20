//
//  GLListOverviewViewController.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/18/15.

#import "GLListOverviewTableViewController.h"
#import "GLListObject.h"
#import "GLUser.h"
#import "PFQuery+GLQuery.h"
#import "GLListOverviewTableViewCell.h"
#import "GLListTableViewController.h"
#import "GLShareCartViewController.h"

static NSString *const kGLListOverviewTableViewControllerReuseIdentifier = @"GLListTableViewController";

@interface GLListOverviewTableViewController ()
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (nonatomic) GLListTableViewController *listTableViewController;
@property (nonatomic) GLShareCartViewController *shareCartViewController;
@end

@implementation GLListOverviewTableViewController

+ (instancetype)instance {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:NSStringFromClass([self class]) bundle:nil];
    return [storyboard instantiateInitialViewController];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.paginationEnabled = NO;
        self.loadingViewEnabled = NO;
        self.pullToRefreshEnabled = YES;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            self.listTableViewController = [[GLListTableViewController alloc] initWithStyle:UITableViewStylePlain];
            self.shareCartViewController = [GLShareCartViewController instance];
        });
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(didTapShareCartButton)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [self setToolbarItems:@[flexibleSpace, barButton, flexibleSpace] animated:NO];
}

- (void)viewDidLayoutSubviews {
    self.footerView.frame = self.navigationController.toolbar.bounds;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:NO animated:NO];
}

- (void)didTapShareCartButton {
    [self presentViewController:self.shareCartViewController animated:YES completion:nil];
}

- (RACSignal *)cachedSignalForTable {
    return [[[[GLUser GL_currentUser].following query] fromLocalDatastore] findObjectsInbackgroundWithRACSignal];
}

- (RACSignal *)signalForTable {
    return [[[GLUser GL_currentUser].following query] findObjectsInbackgroundWithRACSignal];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(GLUser *)object {
    GLListOverviewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kGLListOverviewTableViewControllerReuseIdentifier forIndexPath:indexPath];
    
    [cell setCartText:object.username];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.listTableViewController.user = (GLUser *)[self objectAtIndexPath:indexPath];
    [self.navigationController pushViewController:self.listTableViewController animated:YES];
}

@end