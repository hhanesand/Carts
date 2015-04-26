//
//  GLCompanionAnimator.h
//  GroceryList
//
//  Created by Hakon Hanesand on 4/24/15.

#import <Foundation/Foundation.h>

@protocol GLCompanionAnimator <NSObject>

@property (nonatomic, copy) void (^forwardsAction)();
@property (nonatomic, copy) void (^backwardsAction)();

@end
