//
//  PFUser+CAUser.m
//  Carts
//
//  Created by Hakon Hanesand on 4/2/15.

#import <ReactiveCocoa/ReactiveCocoa.h>

#import "PFUser+CAUser.h"

@implementation PFUser (CAUser)

+ (RACSignal *)logInInBackgroundWithUsername:(NSString *)username password:(NSString *)password {
	return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
            if (error) {
                NSLog(@"Error in logInInBackgroundWithUserName %@", error);
                [subscriber sendError:error];
            } else {
                [subscriber sendCompleted];
            }
        }];
        
        return nil;
    }];
}

- (RACSignal *)signUpInBackgroundWithSignal {
	return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                NSLog(@"Error in signUpInBackgroundWithSignal %@", error);
                [subscriber sendError:error];
            } else {
                [PFUser logInWithUsernameInBackground:self.username password:self.password block:^(PFUser *user, NSError *error) {
                    if (error) {
                        NSLog(@"error in login inside sign up %@", error);
                        [subscriber sendError:error];
                    }
                    
                    [subscriber sendNext:self];
                    [subscriber sendCompleted];
                }];
            }
        }];
        
        return nil;
    }];
}

+ (BOOL)isLoggedIn {
    return ![PFAnonymousUtils isLinkedWithUser:[self currentUser]];
}

- (NSString *)bestName {
    if([PFUser currentUser] == self) {
        return @"Your Cart";
    } else {
        return [[self objectForKey:@"name"] stringByAppendingString:@"'s Cart"];
    }

}

- (CAListObject *)list {
    return [self objectForKey:@"list"];
}

- (void)bindWithFacebookGraphRequest:(NSDictionary *)request {
    if (request[@"email"]) {
        self[@"email"] = request[@"email"];
    }
    
    if (request[@"name"]) {
        self[@"name"] = request[@"name"];
        self[@"searchableID"] = [self[@"name"] lowercaseString];
    }
    
    if (request[@"first_name"]) {
        self[@"firstName"] = request[@"first_name"];
    }
    
    if (request[@"last_name"]) {
        self[@"lastName"] = request[@"last_name"];
    }
    
    if (!self[@"searchableID"]) {
        if (self[@"firstName"]) {
            self[@"searchableID"] = self[@"firstName"];
        }
        
        if (self[@"lastName"]) {
            self[@"searchableID"] = [self[@"searchableID"] stringByAppendingString:self[@"lastName"]];
            self[@"searchableID"] = [self[@"searchableID"] lowercaseString];
        }
    }
    
    if (request[@"gender"]) {
        self[@"gender"] = request[@"gender"];
    }
    
    if (request[@"locale"]) {
        self[@"locale"] = request[@"locale"];
    }
}

- (void)bindWithTwitterResponse:(NSDictionary *)response {
    if (response[@"name"]) {
        NSString *name = response[@"name"];
        NSArray *list = [name componentsSeparatedByString:@" "];
        
        self[@"firstName"] = [[list subarrayWithRange:NSMakeRange(0, list.count - 1)] componentsJoinedByString:@" "];
        self[@"lastName"] = [list lastObject];
        
        self[@"name"] = name;
        self[@"searchableID"] = name;
    }
    
    if (response[@"location"]) {
        self[@"locale"] = response[@"location"];
    } else if (response[@"lang"]) {
        self[@"location"] = response[@"lang"];
    }
    
    if (response[@"profile_image_url"]) {
        self[@"picture"] = response[@"profile_image_url"];
    }
}

@end
