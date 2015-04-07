//
//  PFQueryTableViewController+Caching.h
//  GroceryList
//
//  Created by Hakon Hanesand on 2/15/15.

#import "PFQueryTableViewController.h"

/**
 *  Allows subclasses of PFQueryTableViewController to directly access the internal objects managed to said class
 */
@interface PFQueryTableViewController (Caching)

/**
 *  Updates the objects the PFQueryTableViewController uses for its tableView
 *
 *  @param newValues The new list of PFObjects to use for the tableView datasource
 *  @param clear     If yes, remove all previous PFObjects from the internal objects array
 */
- (void)updateInternalObjectsWithArray:(NSArray *)newValues clear:(BOOL)clear;

@end
