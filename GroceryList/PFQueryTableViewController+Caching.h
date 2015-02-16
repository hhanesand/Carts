//
//  PFQueryTableViewController+Caching.h
//  GroceryList
//
//  Created by Hakon Hanesand on 2/15/15.
//
//

#import "PFQueryTableViewController.h"

@interface PFQueryTableViewController (Caching)

- (void)cache_init;
- (void)cache_loadObjectsClear:(BOOL)clear;

@end
