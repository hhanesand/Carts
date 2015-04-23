//
//  GLSignUpViewController.h
//  GroceryList
//
//  Created by Hakon Hanesand on 4/22/15.

#import "PFSignUpViewController.h"
#import "GLSignUpDelegate.h"

@interface GLSignUpViewController : UIViewController

+ (instancetype)instance;

@property (nonatomic) id<GLSignUpDelegate> delegate;

@end
