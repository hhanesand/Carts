//
//  GLQueryTableViewController.h
//  GroceryList
//
//  Created by Hakon Hanesand on 3/11/15.
//
//

#import <Foundation/Foundation.h>
#import "PFQueryTableViewController.h"

/**
 *  Overrides the PFQueryTableViewController's loadObjects:clear: method to use Local Datastore
 */
@interface GLQueryTableViewController : PFQueryTableViewController

@end
