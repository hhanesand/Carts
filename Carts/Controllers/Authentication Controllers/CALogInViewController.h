//
//  CALogInViewController.h
//  GroceryList
//
//  Created by Hakon Hanesand on 4/22/15.

#import "PFLogInViewController.h"
#import "CASignUpDelegate.h"

@interface CALogInViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic) id<CASignUpDelegate> delegate;

@end
