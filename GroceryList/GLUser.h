//
//  GLUser.h
//  GroceryList
//
//  Created by Hakon Hanesand on 4/18/15.

#import <Parse/Parse.h>
#import "GLListObject.h"

@interface GLUser : PFUser<PFSubclassing>

+ (GLUser *)GL_currentUser;
+ (BOOL)isLoggedIn;

@property (nonatomic) GLListObject *list;
@property (nonatomic, readonly) PFRelation *following;

@end
