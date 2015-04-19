//
//  PFObject+GLPFObject.m
//  GroceryList
//
//  Created by Hakon Hanesand on 3/11/15.

#import <ReactiveCocoa/ReactiveCocoa.h>

#import "PFObject+GLPFObject.h"

@implementation PFObject (GLPFObject)

+ (RACSignal *)pinAllWithSignal:(NSArray *)objects {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [PFObject pinAllInBackground:objects block:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:error];
            }
        }];
        
        return nil;
    }];
}

+ (RACSignal *)unpinAllWithSignal {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [PFObject unpinAllObjectsInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [subscriber sendCompleted];
        }];
        
        return nil;
    }];
}

+ (RACSignal *)fetchAllWithSignal:(NSArray *)objects {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [PFObject fetchAllInBackground:objects block:^(NSArray *objects, NSError *error) {
            if (error) {
                NSLog(@"Error %@", error);
                [subscriber sendCompleted];
            } else {
                [subscriber sendNext:objects];
            }
        }];
        
        return nil;
    }];
}

- (RACSignal *)pinWithSignal {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self pinInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:error];
            }
        }];
        
        return nil;
    }];
}

- (RACSignal *)saveWithSignal {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:error];
            }
        }];
        
        return nil;
    }];
}

- (RACSignal *)fetchWithSignal {
	return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (error) {
                [subscriber sendError:error];
            } else {
                [subscriber sendNext:object];
                [subscriber sendCompleted];
            }
        }];
        
        return nil;
    }];
}

- (RACSignal *)fetchWithSignalFromLocalDatastore {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self fetchFromLocalDatastoreInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (error) {
                NSLog(@"Error %@", error);
                [subscriber sendCompleted];
            } else {
                [subscriber sendNext:object];
                [subscriber sendCompleted];
            }
        }];
        
        return nil;
    }];
}



@end
