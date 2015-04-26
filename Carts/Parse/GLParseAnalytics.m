//
//  CAParseAnalytics.m
//  GroceryList
//
//  Created by Hakon Hanesand on 2/14/15.

#import <Parse/Parse.h>

#import "CAParseAnalytics.h"
#import "CABarcode.h"

static NSString *const kCAMissingBarcodeCloudFunction = @"trackMissingBarcode";
static NSString *const kCABarcodeCloudFunctionParameter = @"barcode";

@implementation CAParseAnalytics

+ (void)trackMissingBarcode:(CABarcode *)barcode {
    [PFCloud callFunctionInBackground:kCAMissingBarcodeCloudFunction withParameters:@{kCABarcodeCloudFunctionParameter : barcode.barcode}];
}

+ (void)testCloudFunction {
    [PFCloud callFunctionInBackground:@"upcLookup" withParameters:@{@"barcode" : @"0012000001086"} block:^(id object, NSError *error) {
        NSLog(@"Result %@", object);
    }];
}

@end

