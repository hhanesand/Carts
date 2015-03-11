//
//  PFQueryTableViewController+Caching.m
//  GroceryList
//
//  Created by Hakon Hanesand on 2/15/15.
//
//

#import "PFQueryTableViewController+Caching.h"
#import <Parse/Parse.h>

@interface PFQueryTableViewController () {
    NSMutableArray *_mutableObjects;
}
@end

@implementation PFQueryTableViewController (Caching)

- (void)updateInternalObjectsWithArray:(NSArray *)newValues clear:(BOOL)clear {
    if (clear) {
        [_mutableObjects removeAllObjects];
    }
    
    [_mutableObjects addObjectsFromArray:newValues];
}

@end
