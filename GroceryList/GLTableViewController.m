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
#import "GLListObject.h"
#import "GLBarcodeObject.h"
#import "UIColor+GLColor.h"

#import <Tweaks/FBTweakStore.h>
#import <Tweaks/FBTweakCategory.h>
#import "GLTweakCollection.h"

#import "PFObject+GLPFObject.h"
#import "GLFadeTransition.h"

static NSString *reuseIdentifier = @"GLTableViewCellIdentifier";

#define TICK   NSDate *startTime = [NSDate date]
#define TOCK   NSLog(@"Time GLTableViewController: %f", -[startTime timeIntervalSinceNow])

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
        self.localDatastoreTag = @"groceryList";
        
        self.title = @"Grocery List";
        
        
        self.scanner = [[GLScannerViewController alloc] init];
        self.scanner.delegate = self;
        
//        self.scanner.modalPresentationStyle = UIModalPresentationCustom;
//        self.scanner.transitioningDelegate = self;
        
        [self tweaks];
    }
    
    return self;
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    [super didMoveToParentViewController:parent];
    NSLog(@"Did move to super controller %@", parent);
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    [super willMoveToParentViewController:parent];
    NSLog(@"Will move to super view controller %@", parent);
}

#pragma mark - View Controller Transitioning Delegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [GLFadeTransition transitionWithPresentation:NO];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [GLFadeTransition transitionWithPresentation:YES];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(didPressAddButton)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [self setToolbarItems:[NSArray arrayWithObjects:flexibleSpace, button, flexibleSpace, nil]];
    
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 8, 0, 8);
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([GLTableViewCell class]) bundle:nil] forCellReuseIdentifier:reuseIdentifier];
    
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.transitioningDelegate = self;
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
    NSLog(@"%ld", self.modalPresentationStyle);
    NSLog(@"%@", self.transitioningDelegate);
    [self presentViewController:self.scanner animated:YES completion:nil];
}

#pragma mark - Parse

- (PFQuery *)queryForTable {
    PFQuery *query = [GLListObject query];
    [query whereKey:@"owner" equalTo:[PFUser currentUser]];
    [query includeKey:@"item"];
    [query orderByAscending:@"updatedAt"];
    return query;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    GLTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    GLListObject *obj = (GLListObject *)object;
    
    cell.name.text = [obj getName];
    cell.brand.text = [obj getBrand];
    cell.category.text = [obj getCategory];
    
    //no reactive cocoa for this one...
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:obj.item.image[0]]];
    UIImage *image = [UIImage imageNamed:@"document"];
    
    [cell.image setImageWithURLRequest:request placeholderImage:image success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *newImage) {
        cell.image.image = newImage;
        [cell setNeedsLayout];
    } failure:nil];
    
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

- (void)didRecieveNewListItem:(GLListObject *)listItem {
    [[[[listItem pinWithSignalAndName:@"groceryList"] doCompleted:^{
        [self loadObjects];
    }] concat:[listItem saveWithSignal]] subscribeCompleted:^{
        NSLog(@"Saved");
    }];
}

#pragma mark - Tweaks

- (void)tweaks {
    [GLTweakCollection defineTweakCollectionInCategory:@"Color" collection:@"Navigation Bar" withType:GLTweakUIColor andObserver:self];
    [GLTweakCollection defineTweakCollectionInCategory:@"Color" collection:@"Tint" withType:GLTweakUIColor andObserver:self];
}

- (void)tweakCollection:(GLTweakCollection *)collection didChangeTo:(NSDictionary *)values {
    if ([collection.name isEqualToString:@"Navigation Bar"]) {
        UIColor *color = [UIColor colorWithRed:[values[@"Red"] intValue] green:[values[@"Green"] intValue] blue:[values[@"Blue"] intValue]];
        [UINavigationBar appearance].barTintColor = color;
        self.navigationController.navigationBar.barTintColor = color;
        [self.navigationController.navigationBar setNeedsDisplay];
        
#warning remove me before release
        
        UIViewController *visibleViewController = [[UIApplication sharedApplication] keyWindow].rootViewController;
        while (visibleViewController.presentedViewController != nil) {
            visibleViewController = visibleViewController.presentedViewController;
        }
        
        NSArray *subviews = visibleViewController.view.subviews;
        ((UINavigationBar   *)subviews[1]).barTintColor = color;
    } else if ([collection.name isEqualToString:@"Tint"]) {
        UIColor *color = [UIColor colorWithRed:[values[@"Red"] intValue] green:[values[@"Green"] intValue] blue:[values[@"Blue"] intValue]];
        [[[UIApplication sharedApplication] keyWindow] setTintColor:color];
    }
    
    [self.presentedViewController.view setNeedsDisplay];
    [[[UIApplication sharedApplication] keyWindow] setNeedsDisplay];
}


@end
