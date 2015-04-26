//
//  CAFactualSessionManager.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/9/15.

#import <ReactiveCocoa/ReactiveCocoa.h>

#import "CAFactualSessionManager.h"
#import "CAFactualResponseSerializer.h"
#import "CAFactualRequestSerializer.h"

static NSString * const kCAFactualURL = @"http://api.v3.factual.com/t/";
static NSString * const kCAFactualBarcodeEndpoint = @"products-cpg";

@interface CAFactualSessionManager ()
@property (nonatomic) NSDictionary *factualToParseMapping;
@end

@implementation CAFactualSessionManager

+ (instancetype)manager {
    return [[CAFactualSessionManager alloc] init];
}

- (instancetype)init {
    if (self = [super initWithBaseURL:[NSURL URLWithString:kCAFactualURL]]) {
        self.responseSerializer = [CAFactualResponseSerializer serializer];
        self.requestSerializer = [CAFactualRequestSerializer serializer];
    }
    
    return self;
}

- (RACSignal *)queryFactualForBarcode:(NSString *)barcode {
    return [[self GET:kCAFactualBarcodeEndpoint parameters:@{@"q" : barcode}] map:^NSDictionary *(NSDictionary *factualJSONResponse) {
        return [self modifyFactualResponseForParseUpload:factualJSONResponse];
    }];
}

- (NSDictionary *)modifyFactualResponseForParseUpload:(NSDictionary *)factualResponse {
    NSMutableDictionary *parseCompatibleDictionary = [NSMutableDictionary new];
    
    for (NSString *parseDataField in self.factualToParseMapping) {
        if (factualResponse[parseDataField]) {
            parseCompatibleDictionary[self.factualToParseMapping[parseDataField]] = factualResponse[parseDataField];
        }
    }
    
    return [parseCompatibleDictionary copy];
}

- (NSDictionary *)factualToParseMapping {
    if (!_factualToParseMapping) {
        _factualToParseMapping =  @{@"brand" : @"brand",
                                   @"category" : @"category",
                                   @"manufacturer" : @"manufacturer",
                                   @"product_name" : @"name",
                                   @"ean13" : @"barcodes",
                                   @"upc" : @"barcodes",
                                   @"upc_e" : @"barcodes",
                                   @"image_urls" : @"image"};
    }
    
    return _factualToParseMapping;
}

@end
