//
//  GLDismissableView.m
//  GroceryList
//
//  Created by Hakon Hanesand on 3/30/15.
//
//

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <pop/POP.h>

#import "GLDismissableView.h"
#import "POPSpringAnimation+GLAdditions.h"

@implementation GLDismissableView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.permissableDeltaForPanGesture = 40;
    }
    
    return self;
}

- (void)didMoveToSuperview {
    UIPanGestureRecognizer *dismiss = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDismiss:)];
    dismiss.delegate = self;
    [self.superview addGestureRecognizer:dismiss];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint location = [gestureRecognizer locationInView:self.superview];
    NSLog(@"Should pan gesture begin? %@", (location.y + self.permissableDeltaForPanGesture) >= CGRectGetMinY(self.frame) ? @"YES" : @"NO");
    return (location.y + self.permissableDeltaForPanGesture) >= CGRectGetMinY(self.frame);
}

- (void)handleDismiss:(UIPanGestureRecognizer *)pan {
    if (pan.state == UIGestureRecognizerStateBegan) {
        [self userDidStartInteractionWithGestureRecognizer:pan];
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        [self userDidPanDismissableViewWithGestureRecognizer:pan];
    } else if (pan.state == UIGestureRecognizerStateEnded) {
        [self userDidEndInteractionWithGestureRecognizer:pan];
    }
}

- (void)userDidStartInteractionWithGestureRecognizer:(UIPanGestureRecognizer *)pan {
    self.initalPosition = self.initalPosition = self.center;
}

- (void)userDidPanDismissableViewWithGestureRecognizer:(UIPanGestureRecognizer *)pan {
    CGPoint translation = [pan translationInView:self.superview];
    CGPoint newCenter = CGPointMake(self.initalPosition.x, self.center.y + translation.y);
    
    if (newCenter.y >= self.initalPosition.y) {
        self.center = newCenter;
        [pan setTranslation:CGPointZero inView:self.superview];
    }
}

- (void)userDidEndInteractionWithGestureRecognizer:(UIPanGestureRecognizer *)pan {
    [self.delegate shouldDismissDismissableView:self withGestureRecognizer:pan];
}

#pragma mark - Presentation

- (RACSignal *)presentView {
    POPSpringAnimation *present = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionY];
    present.toValue = @([self.delegate finalPositionForDismissableView:self inState:GLDismissableViewStatePresented]);
    present.springBounciness = 0;
    
    [self pop_addAnimation:present forKey:@"present_view"];
    
    return [present completionSignal];
}

- (RACSignal *)dismissViewWithPanGestureRecognizer:(UIPanGestureRecognizer *)pan {
    return [self dismissViewWithVelocity:[pan velocityInView:self].y];
}

- (RACSignal *)dismissView {
    return [self dismissViewWithVelocity:200];
}

- (RACSignal *)dismissViewWithVelocity:(CGFloat)velocity {
    POPSpringAnimation *dismiss = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionY];
    dismiss.toValue = @([self.delegate finalPositionForDismissableView:self inState:GLDismissableViewStateDismissed]);
    dismiss.velocity = @(velocity);
    dismiss.springBounciness = 0;
    
    [self pop_addAnimation:dismiss forKey:@"interactive_dismiss"];
    
    return [dismiss completionSignal];
}

@end
