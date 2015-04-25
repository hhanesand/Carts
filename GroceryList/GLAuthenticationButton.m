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

@property (nonatomic) GLAnimation *shake;
@property (nonatomic) GLToggleAnimator *fadeToggleAnimator;

@property (nonatomic) NSString *savedTitle;
@property (nonatomic) UIImage *image;
@end

@implementation GLAuthenticationButton

#pragma mark - Init

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.isExtended = YES;
        [self setMaskToRoundedCorners:UIRectCornerAllCorners withRadii:4.0];
        self.savedTitle = [self titleForState:UIControlStateNormal];
        
        self.image =  [UIImage imageNamed:@"done"];
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

    [self.fadeToggleAnimator toggleAnimation];
}

- (void)setActivityIndicatorView:(MRActivityIndicatorView *)activityIndicatorView {
    _activityIndicatorView = activityIndicatorView;
    
    self.activityIndicatorView.layer.opacity = 0;
    self.activityIndicatorView.hidesWhenStopped = YES;
    self.activityIndicatorView.hidden = YES;
    
    if (self.shouldAnimate) {
        self.fadeToggleAnimator = [GLToggleAnimator animatorWithTarget:self.activityIndicatorView.layer property:kPOPLayerOpacity startValue:@(0) endValue:@(1)];
        
        @weakify(self);
        self.fadeToggleAnimator.forwardsAction = ^{
            @strongify(self);
            [self setTitle:@"" forState:UIControlStateNormal];
            [self.activityIndicatorView startAnimating];
        };
        
        self.fadeToggleAnimator.backwardsAction = ^{
            @strongify(self);
            [self setTitle:self.savedTitle forState:UIControlStateNormal];
            [self.activityIndicatorView stopAnimating];
        };
    }
}

- (void)animateError {
    POPSpringAnimation *animation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionX];
    animation.velocity = @2000;
    animation.springBounciness = 20;
    animation.springSpeed = 20;
    
    POPSpringAnimation *ani = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionX];
    ani.velocity = @2000;
    ani.springBounciness = 20;
    ani.springSpeed = 20;
    
    [self.activityIndicatorView.layer pop_addAnimation:animation forKey:@"ani"];
    [self.layer pop_addAnimation:ani forKey:@"aani"];
    
    [self.fadeToggleAnimator toggleAnimation];
}

- (void)animateSuccess {
    [self.activityIndicatorView stopAnimating];
    [self setTitle:@"" forState:UIControlStateNormal];
    [self setImage:self.image forState:UIControlStateNormal];
}

@end
