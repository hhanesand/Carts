//
//  PFTwitterUtils+CATwitterUtils.h
//  GroceryList
//
//  Created by Hakon Hanesand on 4/25/15.

#import <Parse/Parse.h>

@class RACSignal;

@interface PFTwitterUtils (CATwitterUtils)

+ (RACSignal *)logInWithSignal;

@end
