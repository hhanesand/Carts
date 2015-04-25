//
//  PFUser+GLUser.h
//  GroceryList
//
//  Created by Hakon Hanesand on 4/2/15.]

#import <Parse/Parse.h>

@class GLListObject;
@class RACSignal;

/**
 *  Reactive Cocoa extensions for the Parse API
 */
@interface PFUser (GLUser)

+ (RACSignal *)logInInBackgroundWithUsername:(NSString *)username password:(NSString *)password;

- (RACSignal *)signUpInBackgroundWithSignal;

+ (BOOL)isLoggedIn;
- (NSString *)bestName;
- (GLListObject *)list;

@end
