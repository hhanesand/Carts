#import <UIKit/UIKit.h>

@interface GLAuthenticationButton : UIButton

@property (nonatomic, weak) IBOutlet MRActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonLayoutConstraint;

@property (nonatomic) IBInspectable BOOL shouldAnimate;

@end
