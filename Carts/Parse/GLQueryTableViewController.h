//
//  GLQueryTableViewController.h
//  GroceryList
//
//  Created by Hakon Hanesand on 3/11/15.

#import <ReactiveCocoa/ReactiveCocoa.h>

#import "PFQueryTableViewController.h"

@import Foundation;

static NSString *const kGLCacheResponseKey;
static NSString *const kGLNetworkResponseKey;

/**
 *  Overrides the PFQueryTableViewController's loadObjects:clear: method to use Local Datastore
 */
@interface GLQueryTableViewController : PFQueryTableViewController

- (RACSignal *)signalForTable;
- (RACSignal *)cachedSignalForTable;

@end
