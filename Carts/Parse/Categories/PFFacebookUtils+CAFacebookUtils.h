//
//  PFFacebookUtils+CAFacebookUtils.h
//  GroceryList
//
//  Created by Hakon Hanesand on 4/24/15.

#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface PFFacebookUtils (CAFacebookUtils)

+ (RACSignal *)logInWithSignalWithReadPermissions:(NSArray *)permissions;

@end
