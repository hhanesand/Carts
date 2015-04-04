//
//  GLVideoPreviewView.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/3/15.

#import "GLVideoPreviewView.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <POP/POP.h>
#import "POPAnimation+GLAnimation.h"

@interface GLVideoPreviewView ()
@property (nonatomic) UIImageView *imageView;
@end

@implementation GLVideoPreviewView

- (instancetype)initWithPreviewLayer:(AVCaptureVideoPreviewLayer *)previewLayer {
    if (self = [super init]) {
        self.imageView = [UIImageView new];
        self.previewLayer = previewLayer;
        [self.layer addSublayer:self.previewLayer];
        self.previewLayer.connection.enabled = YES;
    }
    
    return self;
}

- (void)resume {
    self.previewLayer.connection.enabled = YES;
    
    [self.layer addSublayer:self.previewLayer];
    
    POPBasicAnimation *alpha = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerOpacity];
    alpha.toValue = 0;
    alpha.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    alpha.duration = 0.2;
    
    [self.imageView.layer pop_addAnimation:alpha forKey:@"fade"];
    
    [[alpha completionSignal] subscribeCompleted:^{
        [self.imageView removeFromSuperview];
    }];
}

- (void)pauseWithImage:(UIImage *)image {
    self.previewLayer.connection.enabled = NO;
    
    self.imageView.image = image;
    [self addSubview:self.imageView];
    [self.previewLayer removeFromSuperlayer];
}

- (void)setFrame:(CGRect)frame {
    self.previewLayer.frame = frame;
    [super setFrame:frame];
}

@end
