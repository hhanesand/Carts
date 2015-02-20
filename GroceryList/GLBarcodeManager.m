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
#import <AFNetworking-RACExtensions/AFHTTPRequestOperationManager+RACSupport.h>

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
        self.factualNetworkingManager.responseSerializer = [AFJSONResponseSerializer serializer];
        self.factualNetworkingManager.requestSerializer = [GLFactualRequestSerializer serializer];
        
        self.factualToParseMapping = @{@"brand" : @"brand",
                                       @"category" : @"category",
                                       @"manufacturer" : @"manufacturer",
                                       @"image_urls" : @"image",
                                       @"ean13" : @"ean13",
                                       @"factual_id" : @"factual_id",
                                       @"product_name" : @"name",
                                       @"upc" : @"upc",
                                       @"upc_e" : @"upc_e"};
    }
    
    return self;
}

- (void)addBarcodeDatabase:(GLBarcodeDatabase *)database {
    [self.databases addObject:database];
}

- (RACSignal *)queryFactualForItemWithUPC:(NSString *)barcode {
    return [[self.factualNetworkingManager rac_GET:@"http://api.v3.factual.com/t/products-cpg" parameters:@{@"q" : barcode}] map:^id(RACTuple *value) {
        NSDictionary *dictionary = (NSDictionary *)value.second;
        return [self modifyFactualResponseForParseUpload:[dictionary valueForKeyPath:@"response.data"][0]];
    }];
}

- (NSDictionary *)modifyFactualResponseForParseUpload:(NSDictionary *)factualResponse {
    NSMutableDictionary *parseCompatibleDictionary = [NSMutableDictionary new];
    
    for (NSString *key in [factualResponse allKeys]) {
        if ([self.factualToParseMapping objectForKey:key]) {
            parseCompatibleDictionary[self.factualToParseMapping[key]] = factualResponse[key];
        }
    }
    
    return [parseCompatibleDictionary copy];
}

//    //go though each database that has been added and grab a signal for the network request
//    for (GLBarcodeDatabase *database in self.databases) {
//        [signals addObject:[[[[self.manager rac_GET:[database getURLForDatabaseWithBarcode:barcode] parameters:nil] map:^id(RACTuple *value) {
//            return [((NSDictionary *)value.second) valueForKeyPath:database.path];
//        }] doError:^(NSError *error) {
//            NSLog(@"Error while fetching name from database %@", error);
//        }] filter:^BOOL(NSString *name) {
//            return [self isValidNameForItem:name];
//        }]];
//    }
//
//    return [[[RACSignal merge:signals] doNext:^(NSString *x) {
//        [recievedNames addObject:x];
//    }] then:^RACSignal *{
//        return [RACSignal return:[self optimalNameForBarcodeProductWithNameCollection:recievedNames]];
//    }];


////this has to be here until the developer behind searchupc.com gets his shit together
//- (BOOL)isValidNameForItem:(id)name {
//    return name && name != [NSNull null] && ![name isEqualToString:@" "] && ![name isEqualToString:@"(null)"];
//}

//- (NSString *)optimalNameForBarcodeProductWithNameCollection:(NSMutableArray *)names {
//    NSLog(@"Names recieved %@", names);
//    NSMutableDictionary *wordDictionary = [[NSMutableDictionary alloc] init];
//    NSMutableArray *result = [NSMutableArray new];
//    
//    for (NSString *nameOfScannedItem in names) {
//        NSArray *scannedItemWords = [nameOfScannedItem componentsSeparatedByString:@" "];
//        
//        for (NSString *word in scannedItemWords) {
//            int numberOfOccurences = [[wordDictionary objectForKey:[word lowercaseString]] intValue];
//            
//            if (numberOfOccurences == 0) {
//                //add a new entry
//                [wordDictionary setObject:[NSNumber numberWithInt:1] forKey:[word lowercaseString]];
//            } else {
//                //already exists, so we increment occurence
//                [wordDictionary setObject:[NSNumber numberWithInt:++numberOfOccurences] forKey:[word lowercaseString]];
//            }
//            
//        }
//    }
//    
//    for (NSString *key in [wordDictionary allKeys]) {
//        if ([[wordDictionary valueForKey:key] intValue] > 1) {
//            [result addObject:key];
//        }   
//    }
//    
//    return [[[result copy] componentsJoinedByString:@" "] capitalizedString];
//}

@end


