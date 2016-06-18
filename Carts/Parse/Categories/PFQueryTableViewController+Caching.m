//
//  PFQueryTableViewController+Caching.m
//  Carts
//
//  Created by Hakon Hanesand on 2/15/15.

#import <Parse/Parse.h>

#import "PFQueryTableViewController+Caching.h"

@interface PFQueryTableViewController () {
    NSMutableArray *_mutableObjects;
}
@end

@implementation PFQueryTableViewController (Caching)

- (void)updateInternalObjectsWithArray:(NSArray *)newValues {
    [_mutableObjects removeAllObjects];
    [_mutableObjects addObjectsFromArray:newValues];
}

@end
