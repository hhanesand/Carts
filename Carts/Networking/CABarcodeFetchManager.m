//
//  CABarcodeFetchManager.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/2/15.

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <Parse/Parse.h>
#import <SVProgressHUD/SVProgressHUD.h>

#import "CABarcodeFetchManager.h"
#import "CABarcodeObject.h"
#import "CAListObject.h"
#import "CABarcode.h"
#import "CAParseAnalytics.h"

#import "PFQuery+CAQuery.h"
#import "CAFactualSessionManager.h"
#import "CABingSessionManager.h"

@interface CABarcodeFetchManager ()
@property (nonatomic) CAFactualSessionManager *factual;
@property (nonatomic) CABingSessionManager *bing;
@end

@implementation CABarcodeFetchManager

- (PFQuery *)queryForBarcode:(CABarcode *)item {
    PFQuery *query = [CABarcodeObject query];
    [query whereKey:@"barcodes" equalTo:item.barcode];
    return query;
}

- (RACSignal *)fetchProductInformationForBarcode:(CABarcode *)barcode {    
    PFQuery *productQuery = [self queryForBarcode:barcode];

    return [[productQuery getFirstObjectWithRACSignal] catch:^RACSignal *(NSError *error) {
        return [[self fetchProductInformationFromFactualForBarcode:barcode] doError:^(NSError *error) {
            [CAParseAnalytics trackMissingBarcode:barcode];
        }];
    }];
}

- (RACSignal *)fetchProductInformationFromFactualForBarcode:(CABarcode *)barcode {
    return [[[self.factual queryFactualForBarcode:barcode.barcode] map:^id(NSDictionary *itemInformation) {
        return [CABarcodeObject objectWithDictionary:itemInformation];
    }] doNext:^(CABarcodeObject *barcodeObject) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[self.bing bingImageRequestWithBarcodeObject:barcodeObject] subscribeNext:^(NSArray *imageURLS) {
                [barcodeObject addImageURLSFromArray:imageURLS];
                [barcodeObject saveEventually];
            }];
        });
    }];
}

- (CAFactualSessionManager *)factual {
    if (!_factual) {
        _factual = [CAFactualSessionManager manager];
    }
    
    return _factual;
}

- (CABingSessionManager *)bing {
    if (!_bing) {
        _bing = [CABingSessionManager manager];
    }
    
    return _bing;
}

@end
