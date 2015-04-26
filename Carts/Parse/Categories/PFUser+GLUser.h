//
//  PFUser+CAUser.h
//  GroceryList
//
//  Created by Hakon Hanesand on 4/2/15.]

#import <Parse/Parse.h>

@class CAListObject;
@class RACSignal;

/**
 *  Reactive Cocoa extensions for the Parse API
 */
@interface PFUser (CAUser)

+ (RACSignal *)logInInBackgroundWithUsername:(NSString *)username password:(NSString *)password;

- (RACSignal *)signUpInBackgroundWithSignal;

+ (BOOL)isLoggedIn;
- (NSString *)bestName;
- (CAListObject *)list;

- (void)bindWithFacebookGraphRequest:(NSDictionary *)request;
- (void)bindWithTwitterResponse:(NSDictionary *)response;

@end
