//
//  GLDismissableViewHandler.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/2/15.

#import <POP/POP.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

#import "GLDismissableViewHandler.h"

#import "POPSpringAnimation+GLAdditions.h"
#import "POPAnimation+GLAnimation.h"
#import "SVProgressHUD.h"

@interface GLDismissableViewHandler ()
@property (nonatomic, weak) UIView *dismissableView;

/**
 *  The y value of the top of the view when it is in its dismissed state
 */
@property (nonatomic) CGFloat dismissedPosition;

/**
 *  The y value of the top of the view when it is presented
 */
@property (nonatomic) CGFloat presentedPosition;

@property (nonatomic) CGFloat threshold;
@end

@implementation GLDismissableViewHandler

- (instancetype)initWithView:(UIView *)view finalPosition:(CGFloat)finalPosition {
    if (self = [super init]) {
        self.dismissableView = view;
        
        self.enabled = YES;
        self.dismissedPosition = view.center.y;
        self.presentedPosition = finalPosition + CGRectGetHeight(self.dismissableView.frame) / 2;
        self.threshold = finalPosition;
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
    [self.dismissableView pop_removeAllAnimations];
}

- (void)userDidPanDismissableViewWithGestureRecognizer:(UIPanGestureRecognizer *)pan {
    CGPoint locationOfFinger = [pan locationInView:pan.view];
    NSLog(@"Location of finger %f", locationOfFinger.y);
    
    if (locationOfFinger.y >= self.threshold) {
        self.dismissableView.center = CGPointSetY(self.dismissableView.center, locationOfFinger.y + CGRectGetHeight(self.dismissableView.frame) / 2);
    }
}

- (void)userDidEndInteractionWithGestureRecognizer:(UIPanGestureRecognizer *)pan {
    CGFloat distancePastPresentedPosition = [pan locationInView:self.dismissableView.superview].y - self.threshold;
    CGFloat velocity = [pan velocityInView:self.dismissableView].y;
    CGFloat velocityFactor = velocity / 100;
    
    if (distancePastPresentedPosition + velocityFactor >= CGRectGetHeight(self.dismissableView.frame) / 2) {
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
    POPSpringAnimation *down = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionY];
    down.toValue = @(self.dismissedPosition);
    down.springBounciness = 0;
    down.springSpeed = 20;
    down.velocity = @(velocity);
    down.name = @"DismissInteractiveView";
    
    [self.dismissableView pop_addAnimation:down forKey:@"dismiss_interactive_view"];
    
    return [down completionSignal];
}

- (RACSignal *)presentViewWithVelocity:(CGFloat)velocity {
    POPSpringAnimation *up = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionY];
    up.toValue = @(self.presentedPosition);
    up.springSpeed = 20;
    up.springBounciness = 10;
    up.velocity = @(velocity);
    up.name = @"PresentInteractiveView";
    
    [self.dismissableView pop_addAnimation:up forKey:@"present_interactive_view"];
    
    return [up completionSignal];
}

static inline CGPoint CGPointSetY(CGPoint point, CGFloat y) {
    return CGPointMake(point.x, y);
}

@end
