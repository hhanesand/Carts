//
//  GLTransitionManager.h
//  GroceryList
//
//  Created by Hakon Hanesand on 3/13/15.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GLTransition.h"

@interface GLTransitionManager : NSObject

+ (GLTransitionManager *)sharedInstance;

+ (void)setSharedInstance:(GLTransitionManager *)new;

@property (nonatomic) NSMutableArray *viewControllerStack;
@property (nonatomic) NSUInteger displayIndex;

- (instancetype)initWithRootWindow:(UIWindow *)window;

- (void)pushViewController:(UIViewController *)toViewController withAnimation:(GLTransition *)transition;
- (void)popViewControllerWithAnimation:(GLTransition *)transition;

@end
