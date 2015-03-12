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
#import "PFObject+GLPFObject.h"

@implementation GLQueryTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style localDatastoreTag:(NSString *)tag {
    self.localDatastoreTag = tag;
    return [self initWithStyle:style className:nil];
}

- (void)loadObjects:(NSInteger)page clear:(BOOL)clear {
    NSAssert(!self.paginationEnabled, @"GLQueryTableViewController can not be used with pagination enabled.");
    
    self.loading = YES;
    [self objectsWillLoad];
    
    PFQuery *cacheQuery = [self queryForTable];
    [cacheQuery fromPinWithName:self.localDatastoreTag];
    RACSignal *cacheSignal = [cacheQuery findObjectsInbackgroundWithRACSignal];
    
    PFQuery *netQuery = [self queryForTable];
    RACSignal *netSignal = [netQuery findObjectsInbackgroundWithRACSignal];
    
    @weakify(self);
    [[[[[[cacheSignal doNext:^(NSArray *cacheResponse) {
        if ([cacheResponse count] > 0) { //can't use filter because we still want the empty array to pass though, we just don't need to update
            @strongify(self);
            [self updateInternalObjectsWithArray:cacheResponse clear:clear];
            [self.tableView reloadData];
            [self objectsDidLoad:nil];
        }
    }] combineLatestWith:netSignal] doNext:^(id x) {
        [self.refreshControl endRefreshing]; //end refreshing now because signal may be stopped by filter below
    }] filter:^BOOL(RACTuple *tuple) {
        return [self shouldUpdateTableViewWithCacheResponse:tuple.first andNetworkResponse:tuple.second];
    }] reduceEach:^NSArray *(NSArray *cacheResponse, NSArray *networkResponse) {
        return networkResponse;
    }] subscribeNext:^(NSArray *objects) {
        @strongify(self);
        
        [self updateInternalObjectsWithArray:objects clear:YES];
        [self updateLocalDatastoreWithObjects:objects];
        [self objectsDidLoad:nil];
        
        [self.tableView reloadData];
    }];
}

- (BOOL)shouldUpdateTableViewWithCacheResponse:(NSArray *)cacheResponse andNetworkResponse:(NSArray *)networkResponse {
    if ([cacheResponse isEqualToArray:networkResponse]) {
        return NO;
    }
    
    //the cache has more entries than the cache so we check if all the
    //extra cache objects don't have any object ids (ie they were added locally)
    if ([cacheResponse count] > [networkResponse count]) {
        for (NSUInteger i = [networkResponse count]; i < [cacheResponse count]; i++) {
            if (((PFObject *)cacheResponse[i]).objectId) {
                return YES;
            }
        }
        
        return NO;
    }
    
    //TODO : Figure out how to fix this for client side deletion
    //currently, if the cache has less objects than the net reponse, then it falls though and automatically returns the network response...
    //if I were to check for it, I would need a way of figuring out that the extra net objects are "old" or not needed anymore
    
    return YES;
}

//TODO : more efficient choosing of what to pin and unpin?
- (void)updateLocalDatastoreWithObjects:(NSArray *)array {
    NSAssert(self.localDatastoreTag, @"Local datastore tag must be defined");
    
    RACSignal *unpinSignal = [[PFObject unpinAllWithSignalAndName:self.localDatastoreTag] catch:^RACSignal *(NSError *error) {
        return [RACSignal empty];
    }];
    
    if ([array count] > 0) {
        unpinSignal = [unpinSignal concat:[PFObject pinAll:array withSignalAndName:self.localDatastoreTag]];
    }
    
    [unpinSignal subscribeCompleted:^{
        NSLog(@"Done");
    }];
}


@end
