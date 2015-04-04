//
//  GLQueryTableViewController.h
//  GroceryList
//
//  Created by Hakon Hanesand on 3/11/15.
//
//

@import Foundation;
#import "PFQueryTableViewController.h"

/**
 *  Overrides the PFQueryTableViewController's loadObjects:clear: method to use Local Datastore
 */
@interface GLQueryTableViewController : PFQueryTableViewController

/**
 *  Initializes and returns a GLQueryTableViewController
 *
 *  @param style The style of the table view
 *  @param tag   The tag this table view controller should use to store the objects it loads in the local datastore
 *
 *  @return A new instance of GLQueryTableViewController
 */
- (instancetype)initWithStyle:(UITableViewStyle)style localDatastoreTag:(NSString *)tag;

/**
 *  The tag this class uses when calling pinWithName: to save objects to the local datastore
 */
@property (nonatomic) NSString *localDatastoreTag;

@end
