//
//  GLQueryTableViewController.m
//  GroceryList
//
//  Created by Hakon Hanesand on 3/11/15.
//
//

#import "GLQueryTableViewController.h"
#import <Parse/Parse.h>
#import "PFQuery+GLQuery.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PFQueryTableViewController+Caching.h"

@implementation GLQueryTableViewController

- (void)loadObjects:(NSInteger)page clear:(BOOL)clear {
    NSAssert(!self.paginationEnabled, @"GLQueryTableViewController can not be used with pagination enabled.");
    
    self.loading = YES;
    [self objectsWillLoad];
    
    PFQuery *cacheQuery = [self queryForTable];
    [cacheQuery fromLocalDatastore];
    RACSignal *cacheSignal = [cacheQuery findObjectsInbackgroundWithRACSignal];
    
    PFQuery *netQuery = [self queryForTable];
    RACSignal *netSignal = [netQuery findObjectsInbackgroundWithRACSignal];
    
    @weakify(self);
    [[RACSignal combineLatest:@[cacheSignal, netSignal] reduce:^id(NSArray *cacheResponse, NSArray *netResponse) {
        @strongify(self);
        return [self mergeCacheResponse:cacheResponse andNetworkResponse:netResponse];
    }] subscribeNext:^(NSArray *objects) {
        @strongify(self);
        self.loading = NO;
        [self updateInternalObjectsWithArray:objects clear:clear];
        [self.tableView reloadData];
        [self objectsDidLoad:nil];
    }];
    
    [cacheSignal subscribeNext:^(NSArray *cacheResponse) {
        @strongify(self);
        [self updateInternalObjectsWithArray:cacheResponse clear:clear];
        [self.tableView reloadData];
        [self objectsDidLoad:nil];
    }];
}
     
- (NSArray *)mergeCacheResponse:(NSArray *)cacheResponse andNetworkResponse:(NSArray *)netResponse {
    if ([cacheResponse isEqualToArray:netResponse]) {
        return cacheResponse;
    }
    
    //the cache has more entries than the cache so we check if all the
    //extra cache objects don't have any object ids (ie they were added locally)
    if ([cacheResponse count] > [netResponse count]) {
        for (NSUInteger i = [netResponse count]; i < [cacheResponse count]; i++) {
            if (!((PFObject *)cacheResponse[i]).objectId) {
                return cacheResponse;
            }
        }
    }
    
    //TODO : Figure out how to fix this for client side deletion
    //currently, if the cache has less objects than the net reponse, then it falls though and automatically returns the network response...
    //if I were to check for it, I would need a way of figuring out that the extra net objects are "old" or not needed anymore
    
    return netResponse;
}


@end
