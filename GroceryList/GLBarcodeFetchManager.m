//
//  GLBarcodeFetchManager.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/2/15.
//
//

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <Parse/Parse.h>

#import "GLBarcodeFetchManager.h"
#import "GLBarcodeObject.h"
#import "GLListObject.h"
#import "GLBarcode.h"
#import "GLParseAnalytics.h"
#import "GLBingFetcher.h"

#import "PFQuery+GLQuery.h"
#import "SVProgressHUD.h"

@interface GLBarcodeFetchManager ()
@property (nonatomic) GLFactualManager *factual;
@property (nonatomic) GLBingFetcher *bing;
@end

@implementation GLBarcodeFetchManager

- (instancetype)init {
    if (self = [super init]) {
        self.factual = [[GLFactualManager alloc] init];
        self.bing = [[GLBingFetcher alloc] init];
    }
    
    return self;
}

- (PFQuery *)queryForBarcode:(GLBarcode *)item {
    PFQuery *query = [GLBarcodeObject query];
    [query whereKey:@"barcodes" equalTo:item.barcode];
    return query;
}

- (RACSignal *)fetchProductInformationForBarcode:(GLBarcode *)barcode {
    [SVProgressHUD show];
    
    PFQuery *productQuery = [self queryForBarcode:barcode];
    
    @weakify(self);
    return [[[[[productQuery getFirstObjectWithRACSignal] catch:^RACSignal *(NSError *error) {
        @strongify(self);
        return [[self fetchProductInformationFromFactualForBarcode:barcode] doError:^(NSError *error) {
            [[GLParseAnalytics shared] trackMissingBarcode:barcode.barcode];
        }];
    }] map:^GLListObject *(GLBarcodeObject *value) {
        return [GLListObject objectWithCurrentUserAndBarcodeItem:value];
    }] doNext:^(id x) {
        [SVProgressHUD showSuccessWithStatus:@"Item found!"];
    }] catch:^RACSignal *(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"Not found :("];
        return [RACSignal return:[GLListObject objectWithCurrentUser]];
    }];
}

- (RACSignal *)fetchProductInformationFromFactualForBarcode:(GLBarcode *)barcode {
    return [[[self.factual queryFactualForBarcode:barcode.barcode] map:^id(NSDictionary *itemInformation) {
        return [GLBarcodeObject objectWithDictionary:itemInformation];
    }] flattenMap:^RACStream *(GLBarcodeObject *barcode) {
        return [self.bing fetchImageURLFromBingForBarcodeObject:barcode];
    }];
}

@end
