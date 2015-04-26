//
//  CAPullToCloseTransitionManager.h
//  GroceryList
//
//  Created by Hakon Hanesand on 3/29/15.

#import "CAReversibleTransition.h"

@import Foundation;
@import UIKit;

@interface CAPullToCloseTransitionManager : NSObject<UIViewControllerAnimatedTransitioning, CAReversibleTransition>

@property (nonatomic) BOOL presenting;

@end
