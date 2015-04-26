//
//  GLPullToCloseTransitionManager.h
//  GroceryList
//
//  Created by Hakon Hanesand on 3/29/15.

#import "GLReversibleTransition.h"

@import Foundation;
@import UIKit;

@interface GLPullToCloseTransitionManager : NSObject<UIViewControllerAnimatedTransitioning, GLReversibleTransition>

@property (nonatomic) BOOL presenting;

@end
