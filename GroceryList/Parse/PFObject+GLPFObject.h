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

+ (RACSignal *)pinAll:(NSArray *)objects withSignalAndName:(NSString *)tagName;

+ (RACSignal *)unpinAllWithSignalAndName:(NSString *)tagName;

- (RACSignal *)saveWithSignal;

- (RACSignal *)pinWithSignalAndName:(NSString *)name;

@end
