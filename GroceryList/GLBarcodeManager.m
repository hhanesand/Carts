//
//  GLBarcodeManager.m
//  GroceryList
//
//  Created by Hakon Hanesand on 1/23/15.
//
//

#import "GLBarcodeManager.h"
#import "GLBarcodeDatabase.h"
#import "GLBarcodeItem.h"
#import "GLBingFetcher.h"
#import "AFURLResponseSerialization.h"
#import "GLFactualRequestSerializer.h"
#import "GLFactualResponseSerializer.h"
#import "AFHTTPRequestOperationManager+RACSupport.h"

@interface GLBarcodeManager()
@property (nonatomic) NSMutableArray *databases;
@property (nonatomic) GLBingFetcher *bingFetcher;
@property (nonatomic) AFHTTPRequestOperationManager *factualNetworkingManager;
@property (nonatomic) RACSignal *networkErrorSignal;
@property (nonatomic) NSDictionary *factualToParseMapping;
@end

@implementation GLBarcodeManager

- (instancetype)init {
    if (self = [super init]) {
        self.databases = [NSMutableArray new];
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
                                       @"upc_e" : @"barcoes"
                                       //@"image_urls" : @"image", images are sketchy now... at least from factual
                                       };
    }
    
    return self;
}

- (void)addBarcodeDatabase:(GLBarcodeDatabase *)database {
    [self.databases addObject:database];
}

- (RACSignal *)queryFactualForItem:(GLBarcodeItem *)barcodeItem {
    NSString *barcode = [barcodeItem getFirstBarcode];
    return [[self.factualNetworkingManager rac_GET:@"http://api.v3.factual.com/t/products-cpg" parameters:@{@"q" : barcode}] map:^id(RACTuple *value) {
        NSDictionary *dictionary = (NSDictionary *)value.second;
        NSLog(@"Factual info %@", dictionary);
        return [self modifyFactualResponseForParseUpload:[dictionary valueForKeyPath:@"response.data"][0]];
    }];
}

- (NSDictionary *)modifyFactualResponseForParseUpload:(NSDictionary *)factualResponse {
    NSMutableDictionary *parseCompatibleDictionary = [NSMutableDictionary new];
    
    for (NSString *key in [factualResponse allKeys]) {
        if (parseCompatibleDictionary[self.factualToParseMapping[key]]) {
            [parseCompatibleDictionary setObject:[NSMutableArray arrayWithObject:factualResponse[key]] forKey:self.factualToParseMapping[key]];
        } else {
            NSMutableArray *array = parseCompatibleDictionary[self.factualToParseMapping[key]];
            [array addObject:factualResponse[key]];
        }
    }
    
    return [parseCompatibleDictionary copy];
}

@end


