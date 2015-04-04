//
//  GLBarcodeManager.m
//  GroceryList
//
//  Created by Hakon Hanesand on 1/23/15.
//
//

#import "GLFactualManager.h"
#import "GLBarcodeObject.h"
#import "GLBingFetcher.h"
#import "AFURLResponseSerialization.h"
#import "GLFactualRequestSerializer.h"
#import "GLFactualResponseSerializer.h"
#import "AFHTTPRequestOperationManager+RACSupport.h"

@interface GLFactualManager()
@property (nonatomic) GLBingFetcher *bingFetcher;
@property (nonatomic) AFHTTPRequestOperationManager *factualNetworkingManager;
@property (nonatomic) NSDictionary *factualToParseMapping;
@end

@implementation GLFactualManager

- (instancetype)init {
    if (self = [super init]) {
        self.bingFetcher = [GLBingFetcher sharedFetcher];
        
        self.factualNetworkingManager= [AFHTTPRequestOperationManager manager];
        self.factualNetworkingManager.responseSerializer = [GLFactualResponseSerializer serializer];
        self.factualNetworkingManager.requestSerializer = [GLFactualRequestSerializer serializer];
        
        self.factualToParseMapping = @{@"brand" : @"brand",
                                       @"category" : @"category",
                                       @"manufacturer" : @"manufacturer",
                                       @"product_name" : @"name",
                                       @"ean13" : @"barcodes",
                                       @"upc" : @"barcodes",
                                       @"upc_e" : @"barcodes"
                                       //@"image_urls" : @"image", images are sketchy now... at least from factual
                                       };
    }
    
    return self;
}

- (RACSignal *)queryFactualForBarcode:(NSString *)barcode {
    RACSignal *factualResponseSignal = [self.factualNetworkingManager rac_GET:@"http://api.v3.factual.com/t/products-cpg" parameters:@{@"q" : barcode}];
    
    return [factualResponseSignal map:^id(NSDictionary *dict) {
//        NSDictionary *dictionary = (NSDictionary *)value.third;
        return [self modifyFactualResponseForParseUpload:[dict valueForKeyPath:@"response.data"][0]];
    }];
}

- (NSDictionary *)modifyFactualResponseForParseUpload:(NSDictionary *)factualResponse {
    NSMutableDictionary *parseCompatibleDictionary = [NSMutableDictionary new];
    
    for (NSString *key in [factualResponse allKeys]) {
        if (!self.factualToParseMapping[key]) {
            continue;
        }
        
        //special handling for the array of barcodes
        if ([self.factualToParseMapping[key] isEqualToString:@"barcodes"]) {
            if (!parseCompatibleDictionary[self.factualToParseMapping[key]]) {
                [parseCompatibleDictionary setObject:[NSMutableArray arrayWithObject:factualResponse[key]] forKey:self.factualToParseMapping[key]];
            } else {
                NSMutableArray *array = parseCompatibleDictionary[self.factualToParseMapping[key]];
                [array addObject:factualResponse[key]];
            }
        } else {
            //this is not an array so we can set the value directly
            [parseCompatibleDictionary setObject:factualResponse[key] forKey:self.factualToParseMapping[key]];
        }
    }
    
    return [parseCompatibleDictionary copy];
}

@end


