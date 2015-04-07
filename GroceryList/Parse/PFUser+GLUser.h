//
//  PFUser+GLUser.h
//  GroceryList
//
//  Created by Hakon Hanesand on 4/2/15.]

#import <Parse/Parse.h>

@class RACSignal;

@interface PFUser (GLUser)

+ (RACSignal *)logInInBackgroundWithUsername:(NSString *)username password:(NSString *)password;

@end
