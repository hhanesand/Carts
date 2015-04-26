//
//  GLBaseViewController.h
//  GroceryList
//
//  Created by Hakon Hanesand on 3/4/15.

#import "GLAnimationStack.h"

@import UIKit;

/**
 * Defines a base view controller that has an Animation Stack to manage animations
 */
@interface GLBaseViewController : UIViewController

@property (nonatomic) GLAnimationStack *animationStack;

- (GLAnimationStack *)animationStack;

@end
