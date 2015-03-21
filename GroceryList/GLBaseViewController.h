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

typedef NS_ENUM(NSInteger, GLTransitionDirection) {
    GLTransitionDirectionPop,
    GLTransitionDirectionPush
};

/**
 *  The stack used by the View Controller to manage animations
 */
@property (nonatomic) GLAnimationStack *animationStack;



@end
