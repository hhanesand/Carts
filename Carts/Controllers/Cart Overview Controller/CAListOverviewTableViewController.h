//
//  CAListOverviewViewController.h
//  GroceryList
//
//  Created by Hakon Hanesand on 4/18/15.

#import "CAQueryTableViewController.h"

@interface CAListOverviewTableViewController : CAQueryTableViewController <UITableViewDataSource, UINavigationControllerDelegate>

/**
 *  Creates and returns a new CAListOverviewTableViewController from its storyboard
 *
 *  @return The new CAListOverviewTableViewController
 */
+ (instancetype)instance;

@end
