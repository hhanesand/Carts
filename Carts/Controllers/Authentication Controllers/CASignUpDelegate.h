//
//  CASignUpDelgate.h
//  GroceryList
//
//  Created by Hakon Hanesand on 4/22/15.

#import <Foundation/Foundation.h>

@protocol CASignUpDelegate <NSObject>

- (void)userDidRequestFacebookAuthentication;
- (void)userDidRequestTwitterAuthentication;

- (void)userDidSignUp;
- (void)userDidLogIn;

@end
