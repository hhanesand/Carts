//
//  GLLogInViewController.h
//  GroceryList
//
//  Created by Hakon Hanesand on 4/22/15.

#import "PFLogInViewController.h"
#import "GLSignUpDelegate.h"

@interface GLLogInViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic) id<GLSignUpDelegate> delegate;

@end
