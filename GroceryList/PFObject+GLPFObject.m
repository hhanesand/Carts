//
//  PFObject+GLPFObject.m
//  GroceryList
//
//  Created by Hakon Hanesand on 3/11/15.
//
//

#import "PFObject+GLPFObject.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation PFObject (GLPFObject)

+ (RACSignal *)pinAll:(NSArray *)objects withSignalAndName:(NSString *)tagName {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSError *error;
        
        if ([PFObject pinAll:objects withName:tagName error:&error]) {
            [subscriber sendCompleted];
        } else {
            [subscriber sendError:error];
        }
        
        return nil;
    }];
}

+ (RACSignal *)unpinAllWithSignalAndName:(NSString *)tagName {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSError *error;
        
        if ([PFObject unpinAllObjectsWithName:tagName error:&error]) {
            [subscriber sendCompleted];
        } else {
            [subscriber sendError:error];
        }
        
        return nil;
    }];
}

- (RACSignal *)saveWithSignal {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSError *error;
        
        if ([self save:&error]) {
            [subscriber sendCompleted];
        } else {
            [subscriber sendError:error];
        }
        
        return nil;
    }];
}

- (RACSignal *)pinWithSignal {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSError *error;
        
        if ([self pin:&error]) {
            [subscriber sendCompleted];
        } else {
            [subscriber sendError:error];
        }
        
        return nil;
    }];
}

- (RACSignal *)pinWithSignalAndName:(NSString *)name {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSError *error;
        
        if ([self pinWithName:name]) {
            [subscriber sendCompleted];
        } else {
            [subscriber sendError:error];
        }
        
        return nil;
    }];
}

- (RACSignal *)pinAndSaveWithSignal {
    return [RACSignal merge:@[[self pinWithSignal], [self saveWithSignal]]];
}

@end
