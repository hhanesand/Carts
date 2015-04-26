//
//  CAListOverviewViewController.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/18/15.

#import "CAListOverviewTableViewController.h"
#import "CAListObject.h"
#import "PFQuery+CAQuery.h"
#import "CAListOverviewTableViewCell.h"
#import "CAListTableViewController.h"
#import "CAShareCartViewController.h"
#import "CASignUpViewController.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "PFUser+CAUser.h"

#import <FBSDKCoreKit/FBSDKGraphRequest.h>
#import "UIImageView+AFNetworking.h"

static NSString *const kCAListOverviewTableViewControllerReuseIdentifier = @"CAListTableViewController";

@interface CAListOverviewTableViewController ()
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (strong, nonatomic) IBOutlet UILabel *navigationBarLabel;
@property (nonatomic) CAListTableViewController *listTableViewController;
@property (nonatomic) CAShareCartViewController *shareCartViewController;
@end

@implementation CAListOverviewTableViewController

+ (instancetype)instance {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:NSStringFromClass([self class]) bundle:nil];
    return [storyboard instantiateInitialViewController];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.paginationEnabled = NO;
        self.loadingViewEnabled = NO;
        self.pullToRefreshEnabled = YES;
        
        CGFloat startTime = CACurrentMediaTime();
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSLog(@"Started loading Storyboards after %f sec", CACurrentMediaTime() - startTime);
            self.listTableViewController = [[CAListTableViewController alloc] initWithStyle:UITableViewStylePlain];
            self.shareCartViewController = [CAShareCartViewController instance];
            NSLog(@"Finished loading Storyboards after %f sec", CACurrentMediaTime() - startTime);
        });
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(didTapShareCartButton)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [self setToolbarItems:@[flexibleSpace, barButton, flexibleSpace] animated:NO];

    UINavigationBar *nav = self.navigationController.navigationBar;
    nav.barTintColor = [UIColor colorWithRed:0.000 green:0.843 blue:0.699 alpha:1];
    nav.barStyle = UIBarStyleBlack;
    nav.tintColor = [UIColor whiteColor];
    
    self.navigationItem.titleView = self.navigationBarLabel;

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.footerView.frame = self.navigationController.toolbar.bounds;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationItem.titleView = self.navigationBarLabel;
    
    [self.navigationController setToolbarHidden:NO animated:NO];
}

- (void)didTapShareCartButton {
    if ([PFUser isLoggedIn]) {
        [self presentViewController:self.shareCartViewController animated:YES completion:nil];
    } else {
        CASignUpViewController *signUp = [CASignUpViewController instance];
        [self presentViewController:signUp animated:YES completion:nil];
    }
}

- (RACSignal *)cachedSignalForTable {
    return [[[[[PFUser currentUser] relationForKey:@"following"] query] fromLocalDatastore] findObjectsInbackgroundWithRACSignal];
}

- (RACSignal *)signalForTable {
    if ([PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]) {
        //fix for wierd parse behavior see http://samwize.com/2014/07/15/pitfall-with-using-anonymous-user-in-parse/
        return [RACSignal empty];
    }
    
    return [[[[PFUser currentUser] relationForKey:@"following"] query] findObjectsInbackgroundWithRACSignal];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFUser *)object {
    CAListOverviewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCAListOverviewTableViewControllerReuseIdentifier forIndexPath:indexPath];
    
    cell.cart.text = [object bestName];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:object[@"picture"]]];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    [cell.image setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        cell.image.image = image;
        [cell.image setNeedsDisplay];
    } failure:nil];
    
    return cell;
}

- (PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return [PFUser currentUser];
    } else {
        return [super objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section]];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [super tableView:tableView numberOfRowsInSection:section] + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.listTableViewController.user = (PFUser *)[self objectAtIndexPath:indexPath];
    [self.navigationController pushViewController:self.listTableViewController animated:YES];
}

@end