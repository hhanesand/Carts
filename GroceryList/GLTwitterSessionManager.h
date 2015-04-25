//
//  GLTwitterSessionManager.h
//  GroceryList
//
//  Created by Hakon Hanesand on 4/25/15.

#import "GLRACSessionManager.h"

@interface GLTwitterSessionManager : GLRACSessionManager

- (RACSignal *)requestTwitterUserWithID:(NSString *)userID;

@end
