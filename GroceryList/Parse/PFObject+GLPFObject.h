//
//  PFObject+GLPFObject.h
//  GroceryList
//
//  Created by Hakon Hanesand on 3/11/15.

#import <Parse/Parse.h>

@class RACSignal;

/**
 *  Reactive Cococa extensions for the Parse API
 */
@interface PFObject (GLPFObject)

+ (RACSignal *)unpinAllWithSignal;
+ (RACSignal *)pinAllWithSignal:(NSArray *)objects;
+ (RACSignal *)fetchAllWithSignal:(NSArray *)objects;

- (RACSignal *)pinWithSignal;
- (RACSignal *)fetchWithSignal;
- (RACSignal *)fetchWithSignalFromLocalDatastore;

@end
