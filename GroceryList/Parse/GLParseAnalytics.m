//
//  GLParseAnalytics.m
//  GroceryList
//
//  Created by Hakon Hanesand on 2/14/15.

#import <Parse/Parse.h>

#import "GLParseAnalytics.h"

@implementation GLParseAnalytics

+ (GLParseAnalytics *)shared {
    static GLParseAnalytics *shared = nil;
    @synchronized(self) {
        if (shared == nil)
            shared = [[self alloc] init];
    }
    
    return shared;
}

- (instancetype)init {
    if (self = [super init]) {
        _missingBarcodeFunctionName = @"trackMissingBarcode";
    }
    
    return self;
}

- (void)trackMissingBarcode:(NSString *)barcode {
    PFObject *missingObject = [PFObject objectWithClassName:@"missing"];
    [missingObject setObject:[PFUser currentUser] forKey:@"user"];
    [missingObject setObject:barcode forKey:@"barcode"];
    
    [missingObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Saved missing barcode");
        } else {
            NSLog(@"Error saving missing barcode %@", error);
        }
    }];
}

- (void)testCloudFunction {
    [PFCloud callFunctionInBackground:@"upcLookup" withParameters:@{@"barcode" : @"0012000001086"} block:^(id object, NSError *error) {
        NSLog(@"Result %@", object);
    }];
}

@end

