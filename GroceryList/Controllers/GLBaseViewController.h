//
//  GLBaseViewController.h
//  GroceryList
//
//  Created by Hakon Hanesand on 3/4/15.
//
//

#import <UIKit/UIKit.h>
#import "GLAnimationStack.h"

/**
 *  Defines the base view controller for almost all VSs used in this project.
 */
@interface GLBaseViewController : UIViewController

@property (nonatomic) GLAnimationStack *animationStack;

- (GLAnimationStack *)animationStack;

@end
