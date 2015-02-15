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

@interface GLBarcodeManager()
@property (nonatomic) NSMutableArray *databases;
@property (nonatomic) NSMutableArray *barcodeItems;
@property (nonatomic) GLBingFetcher *bingFetcher;
@property (nonatomic) AFHTTPRequestOperationManager *manager;
@property (nonatomic) RACSignal *networkErrorSignal;
@end

@implementation GLBarcodeManager

- (instancetype)init {
    if (self = [super init]) {
        self.databases = [NSMutableArray new];
        self.bingFetcher = [GLBingFetcher sharedFetcher];
        self.manager = [AFHTTPRequestOperationManager manager];
        
        self.manager.responseSerializer.acceptableContentTypes = [self.manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
    }
    
    return self;
}

- (void)addBarcodeDatabase:(GLBarcodeDatabase *)database {
    [self.databases addObject:database];
}

- (RACSignal *)fetchNameOfItemWithBarcode:(NSString *)barcode {
    NSMutableArray *recievedNames = [NSMutableArray new];
    NSMutableArray *signals = [NSMutableArray new];
    
    //go though each database that has been added and grab a signal for the network request
    for (GLBarcodeDatabase *database in self.databases) {
        [signals addObject:[[[[self.manager rac_GET:[database getURLForDatabaseWithBarcode:barcode] parameters:nil] map:^id(RACTuple *value) {
            return [((NSDictionary *)value.second) valueForKeyPath:database.path];
        }] doError:^(NSError *error) {
            NSLog(@"Error while fetching name from database %@", error);
        }] filter:^BOOL(NSString *name) {
            return [self isValidNameForItem:name];
        }]];
    }

    return [[[RACSignal merge:signals] doNext:^(NSString *x) {
        [recievedNames addObject:x];
    }] then:^RACSignal *{
        return [RACSignal return:[self optimalNameForBarcodeProductWithNameCollection:recievedNames]];
    }];
}

//this has to be here until the developer behind searchupc.com gets his shit together
- (BOOL)isValidNameForItem:(id)name {
    return name && name != [NSNull null] && ![name isEqualToString:@" "] && ![name isEqualToString:@"(null)"];
}

- (NSString *)optimalNameForBarcodeProductWithNameCollection:(NSMutableArray *)names {
    NSLog(@"Names recieved %@", names);
    NSMutableDictionary *wordDictionary = [[NSMutableDictionary alloc] init];
    NSMutableArray *result = [NSMutableArray new];
    
    for (NSString *nameOfScannedItem in names) {
        NSArray *scannedItemWords = [nameOfScannedItem componentsSeparatedByString:@" "];
        
        for (NSString *word in scannedItemWords) {
            int numberOfOccurences = [[wordDictionary objectForKey:[word lowercaseString]] intValue];
            
            if (numberOfOccurences == 0) {
                //add a new entry
                [wordDictionary setObject:[NSNumber numberWithInt:1] forKey:[word lowercaseString]];
            } else {
                //already exists, so we increment occurence
                [wordDictionary setObject:[NSNumber numberWithInt:++numberOfOccurences] forKey:[word lowercaseString]];
            }
            
        }
    }
    
    for (NSString *key in [wordDictionary allKeys]) {
        if ([[wordDictionary valueForKey:key] intValue] > 1) {
            [result addObject:key];
        }   
    }
    
    return [[[result copy] componentsJoinedByString:@" "] capitalizedString];
}

@end


