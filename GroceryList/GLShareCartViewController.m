//
//  GLShareTableViewController.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/20/15.

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <Parse/Parse.h>

#import "GLShareCartViewController.h"
#import "GLTransitionDelegate.h"
#import "GLPullToCloseTransitionManager.h"
#import "GLPullToCloseTransitionPresentationController.h"
#import "UISearchBar+RACAdditions.h"
#import "RACSignal+GLAdditions.h"
#import "GLUser.h"
#import "PFQuery+GLQuery.h"
#import "GLUserTableViewCell.h"
#import "GLKeyboardResponderAnimator.h"

static NSString *const kGLFollowUserTableViewCellReuseIdentifier = @"GLFollowUserTableViewIdentifier";

@interface GLShareCartViewController ()
@property (nonatomic) GLTransitionDelegate *transitionDelegate;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic) NSString *previousSearch;
@property (nonatomic) NSArray *searchResults;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (nonatomic) GLKeyboardResponderAnimator *keyboardResponder;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *footerViewLayoutConstraint;
@end

@implementation GLShareCartViewController

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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

- (IBAction)didTapDoneView:(id)sender {
    [self.searchBar resignFirstResponder];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidLoad];
    
    self.keyboardResponder = [[GLKeyboardResponderAnimator alloc] initWithDelegate:self];
    
    [[[self.searchBar.rac_textSignal filter:^BOOL(NSString *search) {
        return [self isValidSearchString:search];
    }] throttle:0.5] subscribeNext:^(NSString *search) {
        [self performQueryWithSearchString:search];
    }];
}

- (BOOL)isValidSearchString:(NSString *)search {
    return search.length >= 2 && ![search isEqualToString:self.previousSearch];
}

- (void)performQueryWithSearchString:(NSString *)search {
    self.previousSearch = search;
    
    PFQuery *query = [GLUser query];
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
    GLUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kGLFollowUserTableViewCellReuseIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    [cell bindWithUser:[self objectForIndexPath:indexPath]];
    return cell;
}

- (void)userDidTapAddFriendButtonInTableViewCell:(GLUserTableViewCell *)cell {
    NSLog(@"Follow button tapped for user with username %@", [self objectForIndexPath:[self.tableView indexPathForCell:cell]].username);
}

- (GLUser *)objectForIndexPath:(NSIndexPath *)indexPath {
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

- (GLTransitionDelegate *)transitionDelegate
{
    if (!_transitionDelegate) {
        _transitionDelegate = [[GLTransitionDelegate alloc] initWithController:self presentationController:[GLPullToCloseTransitionPresentationController class] transitionManager:[GLPullToCloseTransitionManager class]];
    }
    
    return _transitionDelegate;
}

@end
