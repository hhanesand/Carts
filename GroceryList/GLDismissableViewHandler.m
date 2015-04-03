//
//  GLDismissableViewHandler.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/2/15.
//
//

#import <POP/POP.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

#import "GLDismissableViewHandler.h"
#import "POPSpringAnimation+GLAdditions.h"

@interface GLDismissableViewHandler ()
@property (nonatomic, weak) UIView *dimissableView;
@property (nonatomic) CGFloat initialPosition;
@property (nonatomic) CGFloat threshhold;
@end

@implementation GLDismissableViewHandler

- (instancetype)initWithView:(UIView *)view {
    if (self = [super init]) {
        self.dimissableView = view;
        self.initialPosition = CGRectGetMinY(self.dimissableView.frame);
    }
    
    return self;
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
    if (self.threshhold == 0) {
        self.threshhold = CGRectGetMinY(self.dimissableView.frame);
    }
}

- (void)userDidPanDismissableViewWithGestureRecognizer:(UIPanGestureRecognizer *)pan {
    CGPoint locationOfFinger = [pan locationInView:pan.view];
    NSLog(@"Point of finger %@", NSStringFromCGPoint(locationOfFinger));
    
    if (locationOfFinger.y >= self.threshhold) {
        CGRect newFrame = CGRectApplyAffineTransform(self.dimissableView.frame, CGAffineTransformMakeTranslation(0, [pan translationInView:pan.view].y));
        
        if (CGRectGetMinY(newFrame) >= self.threshhold) {
            self.dimissableView.frame = newFrame;
        }
    }
    
    [pan setTranslation:CGPointZero inView:pan.view];
}

- (void)userDidEndInteractionWithGestureRecognizer:(UIPanGestureRecognizer *)pan {
    NSLog(@"Speed %f", [pan velocityInView:pan.view].y);
    if (CGRectGetMinY(self.dimissableView.frame) - self.threshhold + [pan velocityInView:pan.view].y / 4 <= CGRectGetHeight(self.dimissableView.frame) / 2) {
        [self presentViewWithVelocity:[pan velocityInView:pan.view].y];
    } else {
        [self dismissViewWithVelocity:[pan velocityInView:pan.view].y];
    }
}

- (void)dismissViewWithVelocity:(CGFloat)velocity {
    if ([self.delegate respondsToSelector:@selector(willDismissViewAfterUserInteraction)]) {
        [self.delegate willDismissViewAfterUserInteraction];
    }
    
    POPSpringAnimation *down = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionY];
    down.toValue = @(self.initialPosition + CGRectGetHeight(self.dimissableView.frame) / 2);
    down.springBounciness = 0;
    down.springSpeed = 20;
    down.velocity = @(velocity);
    
    [self.dimissableView pop_addAnimation:down forKey:@"present_interactive"];
    
    if ([self.delegate respondsToSelector:@selector(didPresentViewAfterUserInteraction)]) {
        [[down completionSignal] subscribeCompleted:^{
            [self.delegate didPresentViewAfterUserInteraction];
        }];
    }
}

- (void)presentViewWithVelocity:(CGFloat)velocity {
    if ([self.delegate respondsToSelector:@selector(willPresentViewAfterUserInteraction)]) {
        [self.delegate willPresentViewAfterUserInteraction];
    }
    
    POPSpringAnimation *up = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionY];
    up.toValue = @(self.threshhold + CGRectGetHeight(self.dimissableView.frame) / 2);
    up.springSpeed = 20;
    up.springBounciness = 2;
    up.velocity = @(velocity);
    
    [self.dimissableView pop_addAnimation:up forKey:@"dismiss_interactive"];
    
    if ([self.delegate respondsToSelector:@selector(didDismissViewAfterUserInteraction)]) {
        [[up completionSignal] subscribeCompleted:^{
            [self.delegate didDismissViewAfterUserInteraction];
        }];
    }
}

@end
