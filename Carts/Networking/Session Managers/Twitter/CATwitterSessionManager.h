//
//  CATwitterSessionManager.h
//  Carts
//
//  Created by Hakon Hanesand on 4/25/15.

#import "CARACSessionManager.h"

@interface CATwitterSessionManager : CARACSessionManager

- (RACSignal *)requestTwitterUserWithID:(NSString *)userID;

@end
