//
//  CATableViewController.h
//  GroceryList
//
//  Created by Hakon Hanesand on 1/18/15.

#import "CAQueryTableViewController.h"
#import "CABaseViewController.h"

@class RACSignal;
@class PFUser;

/**
 *  The view controller that handles the user's grocery list
 */
@interface CAListTableViewController : CAQueryTableViewController <UITableViewDataSource>

/**
 *  The User's list this table view is currently displaying
 */
@property (nonatomic) PFUser *user;

@end
