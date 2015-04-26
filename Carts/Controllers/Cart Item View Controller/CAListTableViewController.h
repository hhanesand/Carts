//
//  GLTableViewController.h
//  GroceryList
//
//  Created by Hakon Hanesand on 1/18/15.

#import "GLQueryTableViewController.h"
#import "GLBaseViewController.h"

@class RACSignal;
@class PFUser;

/**
 *  The view controller that handles the user's grocery list
 */
@interface GLListTableViewController : GLQueryTableViewController <UITableViewDataSource>

/**
 *  The User's list this table view is currently displaying
 */
@property (nonatomic) PFUser *user;

@end
