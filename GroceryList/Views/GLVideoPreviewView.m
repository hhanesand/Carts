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
    alpha.duration = 0.1;
    
    [self.imageView pop_addAnimation:alpha forKey:@"fade"];
    
    [[alpha completionSignal] subscribeCompleted:^{
        [self.imageView removeFromSuperview];
    }];
}

- (void)pauseWithImage:(UIImage *)image {
    self.imageView = [[UIImageView alloc] initWithImage:image];
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
        _previewView.backgroundColor = [UIColor blueColor];
    }
    
    return _previewView;
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
