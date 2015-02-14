//
//  GLParseAnalytics.m
//  GroceryList
//
//  Created by Hakon Hanesand on 2/14/15.

#import "GLParseAnalytics.h"
#import <Parse/Parse.h>

@implementation GLParseAnalytics

+ (GLParseAnalytics *)shared {
    static GLParseAnalytics *shared = nil;
    @synchronized(self) {
        if (shared == nil)
            shared = [[self alloc] init];
    }
    
    return shared;
}

- (void)trackMissingBarcode:(NSString *)barcode {
    PFObject *object = [PFObject objectWithClassName:@"missingProducts"];
    object[@"barcode"] = barcode;
    [object saveEventually];
    
}

@end

