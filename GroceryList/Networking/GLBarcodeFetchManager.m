//
//  GLBarcodeFetchManager.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/2/15.

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <Parse/Parse.h>
#import <SVProgressHUD/SVProgressHUD.h>

#import "GLBarcodeFetchManager.h"
#import "GLBarcodeObject.h"
#import "GLListObject.h"
#import "GLBarcode.h"
#import "GLParseAnalytics.h"

#import "PFQuery+GLQuery.h"
#import "GLFactualSessionManager.h"
#import "GLBingSessionManager.h"

@interface GLBarcodeFetchManager ()
@property (nonatomic) GLFactualSessionManager *factual;
@property (nonatomic) GLBingSessionManager *bing;
@end

@implementation GLBarcodeFetchManager

- (PFQuery *)queryForBarcode:(GLBarcode *)item {
    PFQuery *query = [GLBarcodeObject query];
    [query whereKey:@"barcodes" equalTo:item.barcode];
    return query;
}

- (RACSignal *)fetchProductInformationForBarcode:(GLBarcode *)barcode {    
    PFQuery *productQuery = [self queryForBarcode:barcode];

    return [[productQuery getFirstObjectWithRACSignal] catch:^RACSignal *(NSError *error) {
        return [[self fetchProductInformationFromFactualForBarcode:barcode] doError:^(NSError *error) {
            [GLParseAnalytics trackMissingBarcode:barcode];
        }];
    }];
}

- (RACSignal *)fetchProductInformationFromFactualForBarcode:(GLBarcode *)barcode {
    return [[[self.factual queryFactualForBarcode:barcode.barcode] map:^id(NSDictionary *itemInformation) {
        return [GLBarcodeObject objectWithDictionary:itemInformation];
    }] doNext:^(GLBarcodeObject *barcodeObject) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[self.bing bingImageRequestWithBarcodeObject:barcodeObject] subscribeNext:^(NSArray *imageURLS) {
                [barcodeObject addImageURLSFromArray:imageURLS];
                [barcodeObject saveEventually];
            }];
        });
    }];
}

- (GLFactualSessionManager *)factual {
    if (!_factual) {
        _factual = [GLFactualSessionManager manager];
    }
    
    return _factual;
}

- (GLBingSessionManager *)bing {
    if (!_bing) {
        _bing = [GLBingSessionManager manager];
    }
    
    return _bing;
}

@end
