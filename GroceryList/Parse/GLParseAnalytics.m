//
//  GLParseAnalytics.m
//  GroceryList
//
//  Created by Hakon Hanesand on 2/14/15.

#import <Parse/Parse.h>

#import "GLParseAnalytics.h"
#import "GLBarcode.h"

static NSString *const kGLMissingBarcodeCloudFunction = @"trackMissingBarcode";
static NSString *const kGLBarcodeCloudFunctionParameter = @"barcode";

@implementation GLParseAnalytics

+ (void)trackMissingBarcode:(GLBarcode *)barcode {
    [PFCloud callFunctionInBackground:kGLMissingBarcodeCloudFunction withParameters:@{kGLBarcodeCloudFunctionParameter : barcode.barcode}];
}

+ (void)testCloudFunction {
    [PFCloud callFunctionInBackground:@"upcLookup" withParameters:@{@"barcode" : @"0012000001086"} block:^(id object, NSError *error) {
        NSLog(@"Result %@", object);
    }];
}

@end

