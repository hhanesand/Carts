//
//  GLListOverviewViewController.h
//  GroceryList
//
//  Created by Hakon Hanesand on 4/18/15.

#import "GLQueryTableViewController.h"

@interface GLListOverviewTableViewController : GLQueryTableViewController <UITableViewDataSource, UINavigationControllerDelegate>

/**
 *  Creates and returns a new GLListOverviewTableViewController from its storyboard
 *
 *  @return The new GLListOverviewTableViewController
 */
+ (instancetype)instance;

@end
