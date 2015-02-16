//
//  PFQueryTableViewController+Caching.m
//  GroceryList
//
//  Created by Hakon Hanesand on 2/15/15.
//
//

#import "PFQueryTableViewController+Caching.h"
#import <Parse/Parse.h>
#import "GLBarcodeItem.h"
#import "BFTask.h"

@interface PFQueryTableViewController () {
    NSMutableArray *_mutableObjects;
    NSInteger _currentPage;
    NSInteger _lastLoadCount;
}
@end

@implementation PFQueryTableViewController (Caching)

- (void)cache_init {
    if (self.pullToRefreshEnabled) {
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self action:@selector(cache_refreshControlValueChanged:) forControlEvents:UIControlEventValueChanged];
        self.refreshControl = refreshControl;
    }
}

//DOES NOT SUPPORT PAGINATION : this method does not attempt to modify the query to support pagination nor does it update the proper vaiables when the cache misses.
//TODO : make this method run the cache and network requests at the same time, but making sure to process the cache first?
- (void)cache_loadObjectsClear:(BOOL)clear {
    NSAssert(!self.paginationEnabled, @"The loadObjectsWithCache method can not be used with pagination enabled.");
    
    self.loading = YES;
    [self objectsWillLoad];
    
    PFQuery *cacheQuery = [self queryForTable];
    [cacheQuery fromLocalDatastore];
    
    [cacheQuery findObjectsInBackgroundWithBlock:^(NSArray *cacheObjects, NSError *error) {
        if (error) {
            NSLog(@"There was an error fetching from cache.");
        } else {
            NSLog(@"Recieved data from the cache %@", cacheObjects);
            [self cache_updateInternalObjectsWithArray:cacheObjects clear:clear];
            [self.tableView reloadData];
        }
        
        PFQuery *networkQuery = [self queryForTable];
        
        [networkQuery findObjectsInBackgroundWithBlock:^(NSArray *netObjects, NSError *error) {
            self.loading = NO;
            
            if (error) {
                NSLog(@"There was an error fetching from the network");
            } else {
                if ([self cache_shouldUpdateDataWithCacheResult:cacheObjects withNewNetworkResults:netObjects]) {
                    NSLog(@"Recieved data from the network %@", netObjects);
                    
                    [[PFObject unpinAllObjectsInBackgroundWithName:@"GLBarcodeItem"] continueWithSuccessBlock:^id(BFTask *ignored) {
                        return [PFObject pinAllInBackground:netObjects withName:@"GLBarcodeItem"];
                    }];
                    
                    [self cache_updateInternalObjectsWithArray:netObjects clear:clear];
                    [self.tableView reloadData];
                } else {
                    NSLog(@"No reason to update tableview");
                }
            }
            
            [self.refreshControl endRefreshing];
            [self objectsDidLoad:error];
        }];
    }];
}



- (void)cache_refreshControlValueChanged:(UIRefreshControl *)refreshControl {
    [self cache_loadObjectsClear:YES];
}

- (void)cache_updateInternalObjectsWithArray:(NSArray *)newValues clear:(BOOL)clear {
    if (clear) {
        [[self cache_getInternalObjects] removeAllObjects];
    }
    
    [[self cache_getInternalObjects] addObjectsFromArray:newValues];
}

- (BOOL)cache_shouldUpdateDataWithCacheResult:(NSArray *)cacheResults withNewNetworkResults:(NSArray *)networkResults {
    if ([cacheResults isEqualToArray:networkResults]) {
        return NO;
    }
    
    if ([cacheResults count] > [networkResults count]) {
        for (NSUInteger i = [networkResults count]; i < [cacheResults count]; i++) {
            if (!((GLBarcodeItem *)cacheResults[i]).wasGeneratedLocally) {
                return YES;
            }
        }
        
        return NO;
    } else {
        return YES;
    }
}

- (NSMutableArray *)cache_getInternalObjects {
    return _mutableObjects;
}

@end
