//
//  GLBingFetcher.m
//  GroceryList
//
//  Created by Hakon Hanesand on 2/7/15.

#import <AFNetworking/AFNetworking.h>
#import <AFNetworking-RACExtensions/AFHTTPRequestOperationManager+RACSupport.h>

#import "GLBingFetcher.h"
#import "GLListObject.h"
#import "GLBarcodeObject.h"

@interface GLBingFetcher()
@property (nonatomic) NSString *root;
@property (nonatomic) NSString *auth;
@property (nonatomic) NSString *thumbnailKeyPath;
@property (nonatomic) AFHTTPRequestOperationManager *manager;
@end

@implementation GLBingFetcher

+ (GLBingFetcher *)sharedFetcher {
    static GLBingFetcher *shared = nil;
    
    @synchronized(self) {
        if (shared == nil)
            shared = [[self alloc] init];
    }

    return shared;
}

- (instancetype)init {
    if (self = [super init]) {
        self.root = @"https://api.datamarket.azure.com/Bing/Search/v1/Image?$format=JSON&$top=1";
        self.thumbnailKeyPath = @"d.results.Thumbnail.MediaUrl";
        self.manager = [AFHTTPRequestOperationManager manager];
        
        NSString *key = @"4RmJ+kjMTCXg36g0LmPrDTiLgF3Xb3EqJjBGwzqXC9A";
        NSData *authData = [[NSString stringWithFormat:@"%@:%@", key, key] dataUsingEncoding:NSUTF8StringEncoding];
        self.auth =  [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]];
    }
    
    return self;
}

- (RACSignal *)fetchImageURLFromBingForBarcodeObject:(GLBarcodeObject *)item {
    NSString *url = [self.root stringByAppendingString:[self nameOfItemToBingPhrase:item.name]];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:self.auth forHTTPHeaderField:@"Authorization"];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    [operation setResponseSerializer:[AFJSONResponseSerializer serializer]];
    
    return [[self.manager rac_enqueueHTTPRequestOperation:operation] map:^GLBarcodeObject *(NSDictionary *responseObject) {
        [item addImageURLSFromArray:[responseObject valueForKeyPath:self.thumbnailKeyPath]];
        return item;
    }];
}

- (NSString *)nameOfItemToBingPhrase:(NSString *)name {
    NSString *result = [name stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    return [[@"&Query=%27" stringByAppendingString:result] stringByAppendingString:@"%27"];
}

@end
