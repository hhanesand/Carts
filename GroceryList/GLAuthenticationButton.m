#import <pop/POP.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <MRProgress/MRActivityIndicatorView.h>

#import "GLAuthenticationButton.h"

#import "UIImage+GLImage.h"
#import "GLRect.h"
#import "UIColor+GLColor.h"
#import "POPAnimation+GLAnimation.h"
#import "UIView+GLView.h"
#import "GLToggleAnimator.h"

@interface GLAuthenticationButton ()
@property (nonatomic) BOOL isExtended;

@property (nonatomic) GLToggleAnimator *widthToggleAnimator;
@property (nonatomic) GLToggleAnimator *fadeToggleAnimator;

@property (nonatomic) NSString *savedTitle;
@end

@implementation GLAuthenticationButton

#pragma mark - Init

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.isExtended = YES;
        [self setMaskToRoundedCorners:UIRectCornerAllCorners withRadii:4.0];
        self.savedTitle = [self titleForState:UIControlStateNormal];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
  
    [self setMaskToRoundedCorners:UIRectCornerAllCorners withRadii:4.0];
//    [self.widthToggleAnimator adjustParametersToStartValue:@(self.buttonLayoutConstraint.constant) endValue:@(CGRectGetWidth(self.activityIndicatorView.bounds) + 16)];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];

    [self.widthToggleAnimator toggleAnimation];
    [self.fadeToggleAnimator toggleAnimation];
}

- (void)setActivityIndicatorView:(MRActivityIndicatorView *)activityIndicatorView {
    _activityIndicatorView = activityIndicatorView;
    
    self.activityIndicatorView.layer.opacity = 0;
    self.activityIndicatorView.hidesWhenStopped = YES;
    self.activityIndicatorView.hidden = YES;
    
    if (self.shouldAnimate) {
        self.fadeToggleAnimator = [GLToggleAnimator animatorWithTarget:self.activityIndicatorView.layer property:kPOPLayerOpacity startValue:@(0) endValue:@(1)];
        
        [self.fadeToggleAnimator performAlongsideForwardAnimation:^{
            [self setTitle:@"" forState:UIControlStateNormal];
            [self.activityIndicatorView startAnimating];
        }];
        
        [self.fadeToggleAnimator performAlongsideBackwardAnimation:^{
            [self setTitle:self.savedTitle forState:UIControlStateNormal];
            [self.activityIndicatorView stopAnimating];
        }];
    }
}

- (void)setButtonLayoutConstraint:(NSLayoutConstraint *)buttonLayoutConstraint {
    _buttonLayoutConstraint = buttonLayoutConstraint;
    
    if (self.shouldAnimate) {
        self.widthToggleAnimator = [GLToggleAnimator animatorWithTarget:self.buttonLayoutConstraint property:kPOPLayoutConstraintConstant startValue:@(self.buttonLayoutConstraint.constant) endValue:@(44)];
    
        self.widthToggleAnimator.forwards.animation.springBounciness = 1;
    }
}

@end
