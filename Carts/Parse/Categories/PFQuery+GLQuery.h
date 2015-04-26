//
//  PFQuery+GLQuery.h
//  GroceryList
//
//  Created by Hakon Hanesand on 3/10/15.

#import <Parse/PFQuery.h>

@class RACSignal;

/**
 *  ReactiveCocoa extensions for the Parse API
 */
@interface PFQuery (GLQuery)

/**
 *  Calls findObjects to perform the query when the returned signal is subscribed to
 *
 *  @return The signal that will send a next event with an NSArray if the query was successful, or an error if not
 */
- (RACSignal *)findObjectsInbackgroundWithRACSignal;


/**
 *  Calls getFirstObject to perform the query when the returned signal is subscriber to
 *
 *  @return The signal that will send a next event with a PFObject if the query was successful, or an error if not
 */
- (RACSignal *)getFirstObjectWithRACSignal;

- (RACSignal *)getObjectWithIdWithSignal:(NSString *)objectId;

@end
