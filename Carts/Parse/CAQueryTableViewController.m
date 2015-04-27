//
//  CAQueryTableViewController.m
//  GroceryList
//
//  Created by Hakon Hanesand on 3/11/15.

#import <Parse/Parse.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

#import "CAQueryTableViewController.h"

#import "PFQuery+CAQuery.h"
#import "PFQueryTableViewController+Caching.h"
#import "PFObject+CAPFObject.h"
#import "CAListObject.h"
#import "MustOverride.h"

static NSString *const kCACacheResponseKey = @"CALocalDatastoreQueryResult";
static NSString *const kCANetworkResponseKey = @"CANetworkQueryResult";

@implementation CAQueryTableViewController

- (void)loadObjects:(NSInteger)page clear:(BOOL)clear {
    NSAssert(!self.paginationEnabled, @"CAQueryTableViewController can not be used with pagination enabled.");
    
    self.loading = YES;
    [self objectsWillLoad];
    
    RACSignal *cacheSignal = [[self cachedSignalForTable] map:^RACTuple *(NSArray *results) {
        return RACTuplePack(kCACacheResponseKey, results);
    }];
    
    RACSignal *networkSignal = [[self signalForTable] map:^RACTuple *(NSArray *results) {
        return RACTuplePack(kCANetworkResponseKey, results);
    }];
    
    [[[[RACSignal merge:@[cacheSignal, networkSignal]] doNext:^(RACTuple *resultTuple) {
        if ([resultTuple.first isEqualToString:kCACacheResponseKey] && [(NSArray *)resultTuple.second count] != 0) {
            [self performTableViewUpdateWithObjects:resultTuple.second];
        }
    }] aggregateWithStart:[[NSMutableDictionary alloc] init] reduce:^id(NSMutableDictionary *running, RACTuple *next) {
        [running setValue:next.second forKey:next.first];
        return running;
    }] subscribeNext:^(NSMutableDictionary *responses) {
        [self.refreshControl endRefreshing];
        self.loading = NO;
        
        if ([self shouldUpdateTableViewWithCacheResponse:responses[kCACacheResponseKey] andNetworkResponse:responses[kCANetworkResponseKey]]) {
            [self performTableViewUpdateWithObjects:responses[kCANetworkResponseKey]];
            
            [[PFObject unpinAllWithSignal] subscribeCompleted:^{
                [PFObject pinAllInBackground:responses[kCANetworkResponseKey] block:^(BOOL succeeded, NSError *error) {
                    if (error) {
                        NSLog(@"Error %@", error);
                    }
                }];
            }];
        }
    }];
}

- (NSArray *)modifyLoadedObjects:(NSArray *)queryResult {
    return queryResult;
}

- (RACSignal *)cachedSignalForTable {
    SUBCLASS_MUST_OVERRIDE;
    return nil;
}

- (RACSignal *)signalForTable {
    SUBCLASS_MUST_OVERRIDE;
    return nil;
}

- (void)performTableViewUpdateWithObjects:(NSArray *)objects {
    [self updateInternalObjectsWithArray:objects];
    [self.tableView reloadData];
    [self objectsDidLoad:nil];
}

- (BOOL)shouldUpdateTableViewWithCacheResponse:(NSArray *)cacheResponse andNetworkResponse:(NSArray *)networkResponse {
    if ([cacheResponse isEqualToArray:networkResponse] || ([cacheResponse count] == 0 && [networkResponse count] == 0)) {
        return NO;
    }
    
    if ([cacheResponse count] > [networkResponse count]) {
        for (NSUInteger i = [networkResponse count]; i < [cacheResponse count]; i++) {
            if (((PFObject *)cacheResponse[i]).objectId) {
                return YES;
            }
        }
        
        return NO;
    }
    
    return YES;
}

@end
