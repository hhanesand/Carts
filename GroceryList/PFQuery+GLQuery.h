//
//  PFQuery+GLQuery.h
//  GroceryList
//
//  Created by Hakon Hanesand on 3/10/15.
//
//

#import <Parse/PFQuery.h>

@class RACSignal;

@interface PFQuery (GLQuery)

/**
 *  Calls 
 *
 *  @return <#return value description#>
 */
- (RACSignal *)findObjectsInbackgroundWithRACSignal;

- (RACSignal *)getFirstObjectWithRACSignal;

@end
