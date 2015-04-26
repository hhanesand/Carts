#import <pop/POP.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <MRProgress/MRActivityIndicatorView.h>

#import "CAAuthenticationButton.h"

#import "UIImage+CAImage.h"
#import "CARect.h"
#import "UIColor+CAColor.h"
#import "POPAnimation+CAAnimation.h"
#import "UIView+CAView.h"
#import "CATogCAeAnimator.h"

@interface CAAuthenticationButton ()
@property (nonatomic) BOOL isExtended;

@property (nonatomic) CAAnimation *shake;
@property (nonatomic) CATogCAeAnimator *fadeTogCAeAnimator;

@property (nonatomic) NSString *savedTitle;
@property (nonatomic) UIImage *savedImage;
@property (nonatomic) UIImage *image;
@end

@implementation CAAuthenticationButton

#pragma mark - Init

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.isExtended = YES;
        [self setMaskToRoundedCorners:UIRectCornerAllCorners withRadii:4.0];
        self.savedTitle = [self titleForState:UIControlStateNormal];
        self.savedImage = [self imageForState:UIControlStateNormal];
        
        self.image =  [UIImage imageNamed:@"done"];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
  
    [self setMaskToRoundedCorners:UIRectCornerAllCorners withRadii:4.0];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];

    [self.fadeTogCAeAnimator togCAeAnimation];
}

- (void)setActivityIndicatorView:(MRActivityIndicatorView *)activityIndicatorView {
    _activityIndicatorView = activityIndicatorView;
    
    self.activityIndicatorView.layer.opacity = 0;
    self.activityIndicatorView.hidesWhenStopped = YES;
    self.activityIndicatorView.hidden = YES;
    
    if (self.shouldAnimate) {
        self.fadeTogCAeAnimator = [CATogCAeAnimator animatorWithTarget:self.activityIndicatorView.layer property:kPOPLayerOpacity startValue:@(0) endValue:@(1)];
        
        @weakify(self);
        self.fadeTogCAeAnimator.forwardsAction = ^{
            @strongify(self);
            [self setTitle:@"" forState:UIControlStateNormal];
            [self setImage:nil forState:UIControlStateNormal];
            [self.activityIndicatorView startAnimating];
        };
        
        self.fadeTogCAeAnimator.backwardsAction = ^{
            @strongify(self);
            [self setTitle:self.savedTitle forState:UIControlStateNormal];
            [self setImage:self.savedImage forState:UIControlStateNormal];
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
    
    [self.fadeTogCAeAnimator togCAeAnimation];
}

- (void)animateSuccess {
    [self.activityIndicatorView stopAnimating];
    [self setTitle:@"" forState:UIControlStateNormal];
    [self setImage:self.image forState:UIControlStateNormal];
}

@end
