//
//  CABaseViewController.h
//  GroceryList
//
//  Created by Hakon Hanesand on 3/4/15.

#import "CAAnimationStack.h"

@import UIKit;

/**
 * Defines a base view controller that has an Animation Stack to manage animations
 */
@interface CABaseViewController : UIViewController

@property (nonatomic) CAAnimationStack *animationStack;

- (CAAnimationStack *)animationStack;

@end
