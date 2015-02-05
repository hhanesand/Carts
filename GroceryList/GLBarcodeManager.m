//
//  GLBarcodeManager.m
//  GroceryList
//
//  Created by Hakon Hanesand on 1/23/15.
//
//

#import "GLBarcodeManager.h"
#import "GLBarcodeDatabase.h"
#import "AFNetworking.h"

@interface GLBarcodeManager()
@property (nonatomic) NSMutableArray *databases;
@property (nonatomic) AFHTTPRequestOperationManager *manager;
@property (nonatomic) int count;
@end

@implementation GLBarcodeManager

- (instancetype)init {
    if (self = [super init]) {
        self.databases = [NSMutableArray new];
        self.manager = [AFHTTPRequestOperationManager manager];
        self.receiveInternetResponseSignal = [RACSubject subject];
        self.count = 5;
    }
    
    return self;
}

- (void)addBarcodeDatabase:(GLBarcodeDatabase *)database {
    [self.databases addObject:database];
}

- (void)addBarcodeDatabaseWithURL:(NSString *)url withReturnType:(GLBarcodeDatabaseReturnType)returnType andSearchBlock:(NSRange (^)(NSString*string, NSString *barcode))searchBlock {
    
    [self addBarcodeDatabase:[[GLBarcodeDatabase alloc] initWithNameOfDatabase:url returnType:returnType andSearchBlock:searchBlock]];
}

- (void)addBarcodeDatabaseWithURL:(NSString *)url withReturnType:(GLBarcodeDatabaseReturnType)returnType searchBlock:(NSRange (^)(NSString*string, NSString *barcode))searchBlock andBarcodeModifier:(NSString *(^)(NSString *))barcodeBlock {
    
    [self addBarcodeDatabase:[[GLBarcodeDatabase alloc] initWithNameOfDatabase:url returnType:returnType searchBlock:searchBlock andBarcodeModifier:barcodeBlock]];
}

- (void)fetchNameOfItemWithBarcode:(NSString *)barcode {
    if ([self.databases count] == 0) {
        NSLog(@"Error, there are no databases to fetch item names from.");
    }
    
    NSLog(@"Fetching results");
    
    for (GLBarcodeDatabase *database in self.databases) {
        NSString *modifiedBarcode = database.barcodeBlock(barcode);
        
        if (database.returnType == GLBarcodeDatabaseJSON) {
            [self.manager GET:[database getURLForDatabaseWithBarcode:modifiedBarcode] parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *response) {
                //ugly hack for now - I need a way to get the key for the name from the user...
                NSLog(@"%@", response[@"name"]);
                [self.receiveInternetResponseSignal sendNext:response[@"name"]];
                [self decrementCountAndCheckForCompletion];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                //[self.receiveInternetResponseSignal sendError:error];
                [self decrementCountAndCheckForCompletion];
            }];
        } else {
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[database getURLForDatabaseWithBarcode:modifiedBarcode]]];
            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                NSRange searchResult = database.searchBlock(string, modifiedBarcode);
                
                if (searchResult.location == NSNotFound) {
                    //[self.receiveInternetResponseSignal sendError:[NSError errorWithDomain:@"Not found" code:1 userInfo:nil]];
                } else {
                    NSLog(@"%@", [string substringWithRange:searchResult]);
                    [self.receiveInternetResponseSignal sendNext:[string substringWithRange:searchResult]];
                }
            
                [self decrementCountAndCheckForCompletion];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                //[self.receiveInternetResponseSignal sendError:error];
                [self decrementCountAndCheckForCompletion];
            }];
            
            [operation start];
        }
    }
}

- (void)decrementCountAndCheckForCompletion {
    self.count--;
    
    if (self.count == 0) {
        [self.receiveInternetResponseSignal sendCompleted];
    }
}

@end


