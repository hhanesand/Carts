//
//  CAQueryTableViewController.h
//  GroceryList
//
//  Created by Hakon Hanesand on 3/11/15.

#import <ReactiveCocoa/ReactiveCocoa.h>

#import "PFQueryTableViewController.h"

@import Foundation;

static NSString *const kCACacheResponseKey;
static NSString *const kCANetworkResponseKey;

/**
 *  Overrides the PFQueryTableViewController's loadObjects:clear: method to use Local Datastore
 */
@interface CAQueryTableViewController : PFQueryTableViewController

- (RACSignal *)signalForTable;
- (RACSignal *)cachedSignalForTable;

@end
