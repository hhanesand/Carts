//
//  CASignUpViewController.h
//  GroceryList
//
//  Created by Hakon Hanesand on 4/22/15.

#import "PFSignUpViewController.h"
#import "CASignUpDelegate.h"

@interface CASignUpViewController : UIViewController <UITextFieldDelegate>

+ (instancetype)instance;

@property (nonatomic) id<CASignUpDelegate> delegate;

@end
