//
//  CAQueryTableViewController.swift
//  Carts
//
//  Created by Hakon Hanesand on 4/27/15.
//  Copyright (c) 2015 Hakon Hanesand. All rights reserved.

import UIKit

struct NetworkResponseKey{
    static let Cache = "kCACacheResponseKey"
    static let Network = "kCANetworkResponseKey"
}

class QueryTableViewController: PFQueryTableViewController {
    
    override func loadObjects(page: Int, clear: Bool) {
        assert(!self.paginationEnabled, "QueryTableViewController can not be used with pagination enabled.")
        
        loading = true
        objectsWillLoad()
        
        let cacheSignal = cachedSignalForTable().map {
            RACTuple(objectsFromArray: $0 as! [AnyObject])
        }
        
        let networkSignal = signalForTable().map {
            RACTuple(objectsFromArray: $0 as! [AnyObject])
        }
        
        RACSignal.merge([cacheSignal, networkSignal]).doNext {
            let tuple = $0 as! RACTuple
        }
//        
//        RACSignal *cacheSignal = [[self cachedSignalForTable] map:^RACTuple *(NSArray *results) {
//            return RACTuplePack(kCACacheResponseKey, results);
//            }];
//        
//        RACSignal *networkSignal = [[self signalForTable] map:^RACTuple *(NSArray *results) {
//            return RACTuplePack(kCANetworkResponseKey, results);
//            }];
//        
//        [[[[RACSignal merge:@[cacheSignal, networkSignal]] doNext:^(RACTuple *resultTuple) {
//            if ([resultTuple.first isEqualToString:kCACacheResponseKey] && [(NSArray *)resultTuple.second count] != 0) {
//                [self performTableViewUpdateWithObjects:resultTuple.second];
//            }
//        }] aggregateWithStart:[[NSMutableDictionary alloc] init] reduce:^id(NSMutableDictionary *running, RACTuple *next) {
//            [running setValue:next.second forKey:next.first];
//            return running;
//        }] subscribeNext:^(NSMutableDictionary *responses) {
//            [self.refreshControl endRefreshing];
//            self.loading = NO;
//            
//            if ([self shouldUpdateTableViewWithCacheResponse:responses[kCACacheResponseKey] andNetworkResponse:responses[kCANetworkResponseKey]]) {
//                [self performTableViewUpdateWithObjects:responses[kCANetworkResponseKey]];
//                
//                [[PFObject unpinAllWithSignal] subscribeCompleted:^{
//                    [PFObject pinAllInBackground:responses[kCANetworkResponseKey] block:^(BOOL succeeded, NSError *error) {
//                    if (error) {
//                    NSLog(@"Error %@", error);
//                    }
//                    }];
//                    }];
//            }
//        }];

    }
    
//    - (void)performTableViewUpdateWithObjects:(NSArray *)objects {
//    [self updateInternalObjectsWithArray:objects];
//    [self.tableView reloadData];
//    [self objectsDidLoad:nil];
//    }
    
//    - (BOOL)shouldUpdateTableViewWithCacheResponse:(NSArray *)cacheResponse andNetworkResponse:(NSArray *)networkResponse {
//    if ([cacheResponse isEqualToArray:networkResponse] || ([cacheResponse count] == 0 && [networkResponse count] == 0)) {
//    return NO;
//    }
//    
//    if ([cacheResponse count] > [networkResponse count]) {
//    for (NSUInteger i = [networkResponse count]; i < [cacheResponse count]; i++) {
//    if (((PFObject *)cacheResponse[i]).objectId) {
//    return YES;
//    }
//    }
//    
//    return NO;
//    }
//    
//    return YES;
//    }
    
    func cachedSignalForTable() -> RACSignal {
        fatalError("cachedSignalForTable() must be overriden in subclass")
    }
    
    func signalForTable() -> RACSignal {
        fatalError("signalForTable() must be overriden in subclass")
    }
    
    func modifyLoadedObjects(objects: [PFObject]) -> [PFObject] {
        return objects
    }
}
