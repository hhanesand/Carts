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
#import "AFNetworking.h"
#import "HTMLReader.h"



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
    }
    
    return self;
}

- (void)addBarcodeDatabase:(GLBarcodeDatabase *)database {
    [self.databases addObject:database];
}

- (void)fetchNameOfItemWithBarcode:(NSString *)barcode {
    if ([self.databases count] == 0) {
        NSLog(@"Error, there are no databases to fetch item names from.");
    }
    
    NSMutableArray *recievedNames = [NSMutableArray new];
    count = 0;
    
    for (GLBarcodeDatabase *database in self.databases) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[database getURLForDatabaseWithBarcode:barcode]]];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        #warning this code shouldn't be duplicated
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            
            NSLog(@"Dictionary for database %@, %@", database.name, dict);
            
            if ([dict valueForKeyPath:database.path]) {
                NSLog(@"Recieved name %@", [dict valueForKeyPath:database.path]);
                NSString *name = [dict valueForKeyPath:database.path];
                
                if (![name isEqual:[NSNull null]] && ![name isEqualToString:@" "]) {
                    [recievedNames addObject:name];
                } else {
                    NSLog(@"Database with name %@ did not have barcode %@", database.name, barcode);
                }
            } else {
                NSLog(@"Database with name %@ did not have barcode %@", database.name, barcode);
            }
            
            count = count + 1;
            
            if (count >= [self.databases count]) {
                [self didFinishFetchingNames:recievedNames forBarcodeItemWithBarcode:barcode];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error while fetching name from server. %@", error);

            count = count + 1;
            
            if (count >= [self.databases count]) {
               [self didFinishFetchingNames:recievedNames forBarcodeItemWithBarcode:barcode];
            }
        }];
        
        [operation start];
    }
}

- (void)didFinishFetchingNames:(NSMutableArray *)names forBarcodeItemWithBarcode:(NSString *)barcode {
    NSString *itemName = [self optimalNameForBarcodeProductWithNameCollection:names];
    GLBarcodeItem *barcodeItem = [[GLBarcodeItem alloc] initWithBarcode:barcode name:itemName];
    [self.bingFetcher fetchImageFormBingForBarcodeItem:barcodeItem];
    [self.barcodeItemSignal sendNext:barcodeItem];
}

- (NSString *)optimalNameForBarcodeProductWithNameCollection:(NSMutableArray *)names {
    NSMutableDictionary *wordDictionary = [[NSMutableDictionary alloc] init];
    
    for (NSString *nameOfScannedItem in names) {
        NSArray *scannedItemWords = [nameOfScannedItem componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" -/."]];
        
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

    
    return [result componentsJoinedByString:@" "];
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


