//
//  GLTransitionContext.h
//  GroceryList
//
//  Created by Hakon Hanesand on 3/12/15.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface GLTransitionContext : NSObject<UIViewControllerContextTransitioning>

- (instancetype)initWithFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController;

@property (nonatomic) RACSignal *completionSignal;
@property (nonatomic) RACSignal *

@end
