//
//  CADismissableViewHandler.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/2/15.

#import <POP/POP.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

#import "CADismissableViewHandler.h"

#import "POPSpringAnimation+CAAdditions.h"
#import "POPAnimation+CAAnimation.h"
#import "SVProgressHUD.h"

@interface CADismissableViewHandler ()
/**
 *  The y value of the top of the view when it is in its dismissed state
 */
@property (nonatomic) CGFloat dismissedPosition;

/**
 *  The y value of the top of the view when it is presented
 */
@property (nonatomic) CGFloat presentedPosition;

/**
 *  The constain the handler should animate to move the animatable view up and down
 */
@property (nonatomic, weak) NSLayoutConstraint *constraint;
@property (nonatomic) CGFloat superviewHeight;
@property (nonatomic) UIView *view;
@end

@implementation CADismissableViewHandler

- (instancetype)initWithAnimatableView:(UIView*)animatableView superViewHeight:(CGFloat)superHeight animatableConstraint:(NSLayoutConstraint *)constraint {
    if (self = [super init]) {
        self.enabled = YES;
        
        self.constraint = constraint;
        self.view = animatableView;
        
        self.superviewHeight = superHeight;
        self.dismissedPosition = constraint.constant;
    }
    
    return self;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return self.enabled;
}

- (void)handlePan:(UIPanGestureRecognizer *)pan {
    if (pan.state == UIGestureRecognizerStateBegan) {
        [self userDidStartInteractionWithGestureRecognizer:pan];
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        [self userDidPanDismissableViewWithGestureRecognizer:pan];
    } else if (pan.state == UIGestureRecognizerStateEnded) {
        [self userDidEndInteractionWithGestureRecognizer:pan];
    }
}

- (void)userDidStartInteractionWithGestureRecognizer:(UIPanGestureRecognizer *)pan {
    [self.constraint pop_removeAllAnimations];
}

- (void)userDidPanDismissableViewWithGestureRecognizer:(UIPanGestureRecognizer *)pan {
    CGPoint locationOfFinger = [pan locationInView:pan.view];
    
    if (locationOfFinger.y >= self.presentedPosition) {
        self.constraint.constant = locationOfFinger.y - self.superviewHeight;
    }
}

- (void)userDidEndInteractionWithGestureRecognizer:(UIPanGestureRecognizer *)pan {
    CGFloat distancePastPresentedPosition = [pan locationInView:pan.view].y - self.presentedPosition;
    CGFloat velocity = [pan velocityInView:pan.view].y;
    CGFloat velocityFactor = velocity / 30;
    
//    NSLog(@"distancePastPresentedPosition %f", distancePastPresentedPosition);
//    NSLog(@"velocityFactor %f", velocityFactor);
    
    if (distancePastPresentedPosition + velocityFactor >= [self height] / 2) {
        if ([self.delegate respondsToSelector:@selector(willDismissViewAfterUserInteraction)]) {
            [self.delegate willDismissViewAfterUserInteraction];
        }
        
        [[self dismissViewWithVelocity:velocity] subscribeCompleted:^{
            if ([self.delegate respondsToSelector:@selector(didDismissViewAfterUserInteraction)]) {
                [self.delegate didDismissViewAfterUserInteraction];
            }
        }];
    } else {
        if ([self.delegate respondsToSelector:@selector(willPresentViewAfterUserInteraction)]) {
            [self.delegate willPresentViewAfterUserInteraction];
        }
        
        [[self presentViewWithVelocity:velocity] subscribeCompleted:^{
            if ([self.delegate respondsToSelector:@selector(didPresentViewAfterUserInteraction)]) {
                [self.delegate didPresentViewAfterUserInteraction];
            }
        }];
    }
}

- (RACSignal *)dismissViewWithVelocity:(CGFloat)velocity {
    POPSpringAnimation *down = [POPSpringAnimation animationWithPropertyNamed:kPOPLayoutConstraintConstant];
    down.toValue = @(self.dismissedPosition);
    down.springBounciness = 0;
    down.springSpeed = 20;
    down.velocity = @(velocity);
    down.name = @"DismissInteractiveView";
    
    [self.constraint pop_addAnimation:down forKey:@"dismiss_interactive_view"];
    
    return [down completionSignal];
}

- (RACSignal *)presentViewWithVelocity:(CGFloat)velocity {
    POPSpringAnimation *up = [POPSpringAnimation animationWithPropertyNamed:kPOPLayoutConstraintConstant];
    up.toValue = @(self.presentedPosition - self.superviewHeight);
    up.springSpeed = 20;
    up.springBounciness = abs(velocity) / 400;
    up.velocity = @(velocity);
    up.name = @"PresentInteractiveView";
    
    [self.constraint pop_addAnimation:up forKey:@"present_interactive_view"];
    
    return [up completionSignal];
}

- (CGFloat)presentedPosition {
    return self.superviewHeight - (self.dismissedPosition + CGRectGetHeight(self.view.frame));
}

- (CGFloat)height {
    return CGRectGetHeight(self.view.frame);
}

@end
