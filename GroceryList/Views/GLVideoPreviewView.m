//
//  GLVideoPreviewView.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/3/15.

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <POP/POP.h>

#import "GLVideoPreviewView.h"

#import "POPAnimation+GLAnimation.h"
#import "UIView+GLView.h"

@interface GLVideoPreviewView ()
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) UIView *previewView;
@end

@implementation GLVideoPreviewView

- (instancetype)initWithPreviewLayer:(AVCaptureVideoPreviewLayer *)previewLayer {
    if (self = [super init]) {
        self.imageView = [UIImageView new];
        self.previewLayer = previewLayer;
    }
    
    return self;
}

- (void)didMoveToSuperview {
    [self addSubview:self.previewView];
}

- (void)resume {
    [self insertSubview:self.previewView belowSubview:self.imageView];
    
    POPBasicAnimation *alpha = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
    alpha.fromValue = @(1);
    alpha.toValue = @(0);
    alpha.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    alpha.duration = 0.5;
    
    [self.imageView pop_addAnimation:alpha forKey:@"fade"];
    
    [[alpha completionSignal] subscribeCompleted:^{
        [self.imageView removeFromSuperview];
    }];
}

- (void)pause {
    self.imageView = [[UIImageView alloc] initWithImage:[self.previewView screenshotInGraphicsContext]];
    self.imageView.frame = self.bounds;
    [self insertSubview:self.imageView aboveSubview:self.previewView];
}

- (void)setFrame:(CGRect)frame {
    self.previewLayer.frame = frame;
    [super setFrame:frame];
}

- (UIView *)previewView {
    if (!_previewView) {
        _previewView = [[UIView alloc] initWithFrame:self.bounds];
        [_previewView.layer addSublayer:self.previewLayer];
    }
    
    return _previewView;
}

@end
