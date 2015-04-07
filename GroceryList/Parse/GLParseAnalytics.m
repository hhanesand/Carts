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
    [PFCloud callFunctionInBackground:self.missingBarcodeFunctionName withParameters:@{@"barcode" : barcode} block:^(id object, NSError *error) {
        NSLog(@"TrackMissingBarcode Result %@", object);
    }];
}

- (void)testCloudFunction {
    [PFCloud callFunctionInBackground:@"upcLookup" withParameters:@{@"barcode" : @"0012000001086"} block:^(id object, NSError *error) {
        NSLog(@"Result %@", object);
    }];
}

@end

