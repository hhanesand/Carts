//
//  CAShareTableViewController.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/20/15.

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <Parse/Parse.h>

#import "CAShareCartViewController.h"
#import "CATransitionDelegate.h"
#import "CAPullToCloseTransitionManager.h"
#import "CAPullToCloseTransitionPresentationController.h"
#import "RACSignal+CAAdditions.h"
#import "PFQuery+CAQuery.h"
#import "CAUserTableViewCell.h"
#import "CAKeyboardResponderAnimator.h"
#import "UIView+CAView.h"

static NSString *const kCAFollowUserTableViewCellReuseIdentifier = @"CAFollowUserTableViewIdentifier";

@interface CAShareCartViewController ()
@property (nonatomic) CATransitionDelegate *transitionDelegate;
@property (weak, nonatomic) IBOutlet UITextField *searchBar;
@property (nonatomic) NSString *previousSearch;
@property (weak, nonatomic) IBOutlet UIView *searchContainer;
@property (nonatomic) NSArray *searchResults;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (nonatomic) CAKeyboardResponderAnimator *keyboardResponder;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *footerViewLayoutConstraint;
@end

@implementation CAShareCartViewController

+ (instancetype)instance {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:NSStringFromClass([self class]) bundle:nil];
    return [storyboard instantiateInitialViewController];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self configureModalPresentation];
    }
        
    return self;
}

- (void)configureModalPresentation {
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.transitioningDelegate = self.transitionDelegate;
    self.modalPresentationCapturesStatusBarAppearance = YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

- (IBAction)didTapDoneView:(id)sender {
    [self.searchBar resignFirstResponder];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didTapSearchView:(id)sender {
    [self.searchBar becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidLoad];
    
    self.keyboardResponder = [[CAKeyboardResponderAnimator alloc] initWithDelegate:self];
    
    [[[self.searchBar.rac_textSignal filter:^BOOL(NSString *search) {
        return [self isValidSearchString:search];
    }] throttle:0.5] subscribeNext:^(NSString *search) {
        [self performQueryWithSearchString:search];
    }];
}

- (void)viewDidLayoutSubviews {
    [self.searchContainer setMaskToRoundedCorners:UIRectEdgeAll withRadii:4.0];
}

- (BOOL)isValidSearchString:(NSString *)search {
    return search.length >= 2 && ![search isEqualToString:self.previousSearch];
}

- (void)performQueryWithSearchString:(NSString *)search {
    self.previousSearch = search;
    
    PFQuery *query = [PFUser query];
    [query whereKey:@"username_lowercase" hasPrefix:[search lowercaseString]];

    [[query findObjectsInbackgroundWithRACSignal] subscribeNext:^(NSArray *result) {
        self.searchResults = result;
        [self.tableView reloadData];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.searchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CAUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCAFollowUserTableViewCellReuseIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    [cell bindWithUser:[self objectForIndexPath:indexPath]];
    return cell;
}

- (void)userDidTapAddFriendButtonInTableViewCell:(CAUserTableViewCell *)cell {
    NSLog(@"Follow button tapped for user with username %@", [self objectForIndexPath:[self.tableView indexPathForCell:cell]].username);
}

- (PFUser *)objectForIndexPath:(NSIndexPath *)indexPath {
    return self.searchResults[indexPath.row];
}

- (UIView *)viewForActiveUserInputElement {
    return self.footerView;
}

- (UIView *)viewToAnimateForKeyboardAdjustment {
    return self.footerView;
}

- (NSLayoutConstraint *)layoutConstraintForAnimatingView {
    return self.footerViewLayoutConstraint;
}

- (CATransitionDelegate *)transitionDelegate
{
    if (!_transitionDelegate) {
        _transitionDelegate = [[CATransitionDelegate alloc] initWithController:self presentationController:[CAPullToCloseTransitionPresentationController class] transitionManager:[CAPullToCloseTransitionManager class]];
    }
    
    return _transitionDelegate;
}

@end
