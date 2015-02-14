//
//  GroceryListTests.m
//  GroceryListTests
//
//  Created by Hakon Hanesand on 1/18/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "GLBarcodeDatabase.h"

@interface GroceryListTests : XCTestCase

@end

@implementation GroceryListTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    NSMutableArray *names = [NSMutableArray new];
    [names addObject:@"Aquafina Purified Drinking Water"];
    [names addObject:@"Aquafina bottle water"];
    [names addObject:@"Red 2001-2007 CHRYSLER VOYAGER / DODGE CARAVAN 3.3 3.3L Air Intake Kit Systems"];
    
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
    
    NSLog(@"Result of test %@", result);
}

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
