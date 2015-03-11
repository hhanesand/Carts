//
//  GLBingFetcher.m
//  GroceryList
//
//  Created by Hakon Hanesand on 2/7/15.
//
//

#import "AFHTTPRequestOperationManager+RACSupport.h"
#import "AFURLResponseSerialization.h"

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

- (RACSignal *)fetchImageURLFromBingForListItem:(GLListObject *)listItem {
    NSString *url = [self.root stringByAppendingString:[self nameOfItemToBingPhrase:listItem.item.name]];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:self.auth forHTTPHeaderField:@"Authorization"];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    [operation setResponseSerializer:[AFJSONResponseSerializer serializer]];
    
    return [[self.manager rac_enqueueHTTPRequestOperation:operation] map:^id(RACTuple *value) {
        NSLog(@"Adding image urls %@", [((NSDictionary *)value.second) valueForKeyPath:self.thumbnailKeyPath]);
        [listItem.item addImageURLSFromArray:[((NSDictionary *)value.second) valueForKeyPath:self.thumbnailKeyPath]];
        return listItem;
    }];
}

- (NSString *)nameOfItemToBingPhrase:(NSString *)name {
    NSString *result = [name stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    return [[@"&Query=%27" stringByAppendingString:result] stringByAppendingString:@"%27"];
}

@end
