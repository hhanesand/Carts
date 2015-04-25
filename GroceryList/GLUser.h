//
//  GLUser.h
//  GroceryList
//
//  Created by Hakon Hanesand on 4/18/15.

#import <Parse/Parse.h>
#import "GLListObject.h"
#import <Parse/PFObject+Subclass.h>

@interface GLUser : PFUser<PFSubclassing>

+ (BOOL)isLoggedIn;

@property (nonatomic) GLListObject *list;
@property (nonatomic) NSString *username_lowercase;
@property (nonatomic, readonly) PFRelation *following;

- (NSString *)bestName;

@end
