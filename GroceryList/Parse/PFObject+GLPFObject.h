//
//  PFObject+GLPFObject.h
//  GroceryList
//
//  Created by Hakon Hanesand on 3/11/15.

#import <Parse/Parse.h>

@class RACSignal;

@interface PFObject (GLPFObject)

+ (RACSignal *)pinAll:(NSArray *)objects withSignalAndName:(NSString *)tagName;

+ (RACSignal *)unpinAllWithSignalAndName:(NSString *)tagName;

- (RACSignal *)saveWithSignal;

- (RACSignal *)pinWithSignalAndName:(NSString *)name;

@end
