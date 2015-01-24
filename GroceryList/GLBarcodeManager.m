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
@end

@implementation GLBarcodeManager

+ (GLBarcodeManager *)sharedManager {
    static GLBarcodeManager *sharedBarcodeManager = nil;
    
    @synchronized(self) {
        if (sharedBarcodeManager == nil) {
            sharedBarcodeManager = [[GLBarcodeManager alloc] init];
        }
    }
    
    return sharedBarcodeManager;
}

- (instancetype)init {
    if (self = [super init]) {
        self.databases = [NSMutableArray new];
        self.manager = [AFHTTPRequestOperationManager manager];
    }
    
    return self;
}

- (void)addBarcodeDatabase:(GLBarcodeDatabase *)database {
    [self.databases addObject:database];
}

- (void)addBarcodeDatabaseWithURL:(NSString *)url withReturnType:(GLBarcodeDatabaseReturnType)returnType andSearchBlock:(NSRange (^)(NSString*string, NSString *barcode))searchBlock {
    
    [self addBarcodeDatabase:[[GLBarcodeDatabase alloc] initWithNameOfDatabase:url returnType:returnType andSearchBlock:searchBlock]];
}

- (NSMutableArray *)fetchNameOfItemWithBarcode:(NSString *)barcode {
    if ([self.databases count] == 0) {
        NSLog(@"Error, there are no databases to fetch item names from.");
    }
    
    NSMutableArray *names = [NSMutableArray new];
    
    for (GLBarcodeDatabase *database in self.databases) {
        if (database.returnType == GLBarcodeDatabaseJSON) {
            [self.manager GET:[database getURLForDatabaseWithBarcode:barcode] parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *response) {
                //ugly hack for now - I need a way to get the key for the name from the user...
                [names addObject:response[@"name"]];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error fetching from JSON database : %@", error);
            }];
        } else {
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[database getURLForDatabaseWithBarcode:barcode]]];
            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                NSRange searchResult = database.searchBlock(string, barcode);
                
                if (searchResult.location == NSNotFound) {

                } else {
                    [names addObject:[string substringWithRange:searchResult]];

                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error fetching from HTML database : %@", error);
            }];
            
            [operation start];
        }
    }
    
    return names;
}

@end


