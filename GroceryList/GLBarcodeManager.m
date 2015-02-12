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
#import "HTMLReader.h"
#import "AFURLResponseSerialization.h"

@interface GLBarcodeManager()
@property (nonatomic) NSMutableArray *databases;
@property (nonatomic) NSMutableArray *barcodeItems;
@property (nonatomic) GLBingFetcher *bingFetcher;
@property (nonatomic) AFHTTPRequestOperationManager *manager;
@end

@implementation GLBarcodeManager

static int count = 0;

- (instancetype)init {
    if (self = [super init]) {
        self.databases = [NSMutableArray new];
        self.bingFetcher = [GLBingFetcher sharedFetcher];
        self.manager = [AFHTTPRequestOperationManager manager];
        self.barcodeItemSignal = [RACSubject subject];
        self.notification = @"barcodeItemUpdatedNotification";
        
        self.manager.responseSerializer.acceptableContentTypes = [self.manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
    }
    
    return self;
}

- (void)addBarcodeDatabase:(GLBarcodeDatabase *)database {
    [self.databases addObject:database];
}

- (RACSignal *)fetchNameOfItemWithBarcode:(NSString *)barcode {
    if ([self.databases count] == 0) {
        NSLog(@"Error, there are no databases to fetch item names from.");
    }
    
    NSMutableArray *recievedNames = [NSMutableArray new];
    NSMutableArray *signals = [NSMutableArray new];
    RACSubject *resultSignal = [RACSubject subject];
    
    [self.databases enumerateObjectsUsingBlock:^(GLBarcodeDatabase *database, NSUInteger index, BOOL *stop) {
        [signals addObject:[[self.manager rac_GET:[database getURLForDatabaseWithBarcode:barcode] parameters:nil] map:^id(RACTuple *value) {
            return [((NSDictionary *)value.second) valueForKeyPath:database.path];
        }]];
    }];
    
    [[RACSignal merge:signals] subscribeNext:^(NSString *x) {
        [recievedNames addObject:x];
    } error:^(NSError *error) {
        NSLog(@"Error while fetching from database %@", error);
    } completed:^{
        [resultSignal sendNext:[self optimalNameForBarcodeProductWithNameCollection:recievedNames]];
        [resultSignal sendCompleted];
    }];
    
    return resultSignal;
}

//this has to be here until the developer behind searchupc.com gets his shit together
- (BOOL)isValidNameForItem:(NSString *)name {
    return ![name isEqualToString:@" "];
}

- (void)didFinishFetchingNames:(NSMutableArray *)names forBarcodeItemWithBarcode:(NSString *)barcode {
    if ([names count] == 0) {
        NSLog(@"No databases replied");
        return;
    }
    
    NSString *itemName = [self optimalNameForBarcodeProductWithNameCollection:names];
    GLBarcodeItem *barcodeItem = [[GLBarcodeItem alloc] initWithBarcode:barcode name:itemName];
    [self.bingFetcher fetchImageFormBingForBarcodeItem:barcodeItem];
    [self.barcodeItemSignal sendNext:barcodeItem];
}

- (NSArray *)optimalNameForBarcodeProductWithNameCollection:(NSMutableArray *)names {
    NSMutableDictionary *wordDictionary = [[NSMutableDictionary alloc] init];
    
    for (NSString *nameOfScannedItem in names) {
        NSArray *scannedItemWords = [nameOfScannedItem componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" -/.,"]];
        
        for (NSString *word in scannedItemWords) {
            int numberOfOccurences = [[wordDictionary objectForKey:[word lowercaseString]] intValue];
            
            if (numberOfOccurences == 0) {
                //this word has not been added to the dictionary yet...
                NSArray *allKeys = [wordDictionary allKeys];
                
                for (NSString *string in allKeys) {
                    //... but let's check if something similar already exists
                    if ([self compareString:string toString:word] > 0.8f) {
                        int newValue = [[wordDictionary objectForKey:string] intValue];
                        [wordDictionary setObject:[NSNumber numberWithInt:++newValue] forKey:[string lowercaseString]];
                        continue;
                    }
                }
                
                //nope, nothing like this word is in the dictionary, so we add a new entry
                [wordDictionary setObject:[NSNumber numberWithInt:1] forKey:[word lowercaseString]];
            } else {
                //already exists, so we increment occurence
                [wordDictionary setObject:[NSNumber numberWithInt:++numberOfOccurences] forKey:[word lowercaseString]];
            }
            
        }
    }
    
    NSMutableArray *allKeys = [[wordDictionary allKeys] mutableCopy];
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:3];
    
    int high = 0;
    NSInteger pos = 0;
    
    //find the 3 words with the highest occurence
    for (int i = 0; i < 3; i++) {
        for (NSString *key in allKeys) {
            if ([[wordDictionary objectForKey:key] intValue] >= high) {
                pos = [allKeys indexOfObject:key];
                high = [[wordDictionary objectForKey:key] intValue];
            }
        }
        
        [result addObject:allKeys[pos]];
        [allKeys removeObjectAtIndex:pos];
        
        high = 0;
        pos = 0;
    }
    
    return [result copy];
}


//returns the percentage of similar characters in a string : comparing "123" and "123" will return 1.0, while comparing "123$" and "1234" will return 0.75.
- (int)compareString:(NSString *)a toString:(NSString *)b {
    double similarCharacters = 0.0;
    
    for (int i = 0; i < MIN(a.length, b.length); i++) {
        if ([a characterAtIndex:i] == [b characterAtIndex:i]) {
            similarCharacters++;
        }
    }
    
    return similarCharacters / (double) MIN(a.length, b.length);
}

@end


