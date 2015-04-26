//
//  GLFactualSessionManager.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/9/15.

#import <ReactiveCocoa/ReactiveCocoa.h>

#import "GLFactualSessionManager.h"
#import "GLFactualResponseSerializer.h"
#import "GLFactualRequestSerializer.h"

static NSString * const kGLFactualURL = @"http://api.v3.factual.com/t/";
static NSString * const kGLFactualBarcodeEndpoint = @"products-cpg";

@interface GLFactualSessionManager ()
@property (nonatomic) NSDictionary *factualToParseMapping;
@end

@implementation GLFactualSessionManager

+ (instancetype)manager {
    return [[GLFactualSessionManager alloc] init];
}

- (instancetype)init {
    if (self = [super initWithBaseURL:[NSURL URLWithString:kGLFactualURL]]) {
        self.responseSerializer = [GLFactualResponseSerializer serializer];
        self.requestSerializer = [GLFactualRequestSerializer serializer];
    }
    
    return self;
}

- (RACSignal *)queryFactualForBarcode:(NSString *)barcode {
    return [[self GET:kGLFactualBarcodeEndpoint parameters:@{@"q" : barcode}] map:^NSDictionary *(NSDictionary *factualJSONResponse) {
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
