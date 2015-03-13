//
//  GLContextTransitioning.h
//  GroceryList
//
//  Created by Hakon Hanesand on 3/13/15.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class RACSignal;

@interface GLTransitioningContext : NSObject

@property (nonatomic, weak) UIView *containerView;
@property (nonatomic, weak) UIViewController *toViewController;
@property (nonatomic, weak) UIViewController *fromViewController;

@property (nonatomic, getter=isAnimated) BOOL animated;
@property (nonatomic, getter=isInteractive) BOOL interactive;

@property (nonatomic) RACSignal *completionSignal;

- (instancetype)initWithFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController;

@end
