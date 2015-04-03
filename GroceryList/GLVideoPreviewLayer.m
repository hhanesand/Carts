//
//  GLVideoPreviewLayer.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/3/15.
//
//

#import "GLVideoPreviewLayer.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <POP/POP.h>
#import "POPAnimation+GLAnimation.h"

@interface GLVideoPreviewLayer ()
@property (nonatomic) CALayer *imageLayer;
@end

@implementation GLVideoPreviewLayer

- (instancetype)initWithPreviewLayer:(AVCaptureVideoPreviewLayer *)previewLayer {
    if (self = [super init]) {
        self.previewLayer = previewLayer;
        self.imageLayer = [CALayer layer];
        [self addSublayer:self.previewLayer];
    }
    
    return self;
}

- (void)start {
    [self insertSublayer:self.previewLayer atIndex:0];
    
    POPBasicAnimation *alpha = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerOpacity];
    alpha.toValue = 0;
    alpha.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    alpha.duration = 0.2;
    
    [self.imageLayer pop_addAnimation:alpha forKey:@"fade"];
    
    [[alpha completionSignal] subscribeCompleted:^{
        [self.imageLayer removeFromSuperlayer];
    }];
}

- (void)pauseWithSignal:(RACSignal *)signal {
	[[signal deliverOnMainThread] subscribeNext:^(id image) {
        self.imageLayer.contents = image;
        [self addSublayer:self.imageLayer];
        [self.previewLayer removeFromSuperlayer];
    }];
}

@end
