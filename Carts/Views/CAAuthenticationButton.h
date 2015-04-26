//
//  CAAuthenticationButton.h
//  GroceryList
//
//  Created by Hakon Hanesand on 4/19/15.

#import <UIKit/UIKit.h>

@interface CAAuthenticationButton : UIButton

@property (nonatomic, weak) IBOutlet MRActivityIndicatorView *activityIndicatorView;

@property (nonatomic) IBInspectable BOOL shouldAnimate;

- (void)animateError;
- (void)animateSuccess;

@end
