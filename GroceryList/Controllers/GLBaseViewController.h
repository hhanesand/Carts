//
//  GLBaseViewController.h
//  GroceryList
//
//  Created by Hakon Hanesand on 3/4/15.

#import "GLAnimationStack.h"

@import UIKit;

/**
 *  Defines the base view controller for almost all VSs used in this project.
 */
@interface GLBaseViewController : UIViewController

@property (nonatomic) GLAnimationStack *animationStack;

- (GLAnimationStack *)animationStack;

@end
