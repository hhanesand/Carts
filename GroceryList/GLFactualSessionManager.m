//
//  GLFactualSessionManager.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/9/15.

#import <ReactiveCocoa/ReactiveCocoa.h>

#import "GLFactualSessionManager.h"
#import "GLFactualResponseSerializer.h"
#import "GLFactualRequestSerializer.h"

NSString * const kGLFactualURL = @"http://api.v3.factual.com/t/";

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

- (instancetype)initWithBaseURL:(NSURL *)url {
    NSAssert(NO, @"Use either +manager or -init to instantiate a GLFactualSessionManager");
    return nil;
}

- (RACSignal *)queryFactualForBarcode:(NSString *)barcode {
    return [[self GET:@"products-cpg" parameters:@{@"q" : barcode}] map:^NSDictionary *(NSDictionary *factualJSONResponse) {
        return [self modifyFactualResponseForParseUpload:factualJSONResponse];
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
