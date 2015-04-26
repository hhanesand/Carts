//
//  CABingSessionManager.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/9/15.

#import <ReactiveCocoa/ReactiveCocoa.h>

#import "CABingSessionManager.h"
#import "CABarcodeObject.h"
#import "CABingRequestSerializer.h"
#import "CABingResponseSerializer.h"

NSString * const kCABingURL = @"https://api.datamarket.azure.com/Bing/Search/v1/";

@interface CABingSessionManager ()
@property (nonatomic) NSString *thumbnailKeyPath;
@end

@implementation CABingSessionManager

+ (instancetype)manager {
    return [[CABingSessionManager alloc] init];
}

- (instancetype)init {
    if (self = [super initWithBaseURL:[NSURL URLWithString:kCABingURL]]) {
        self.requestSerializer = [CABingRequestSerializer serializer];
        self.responseSerializer = [CABingResponseSerializer serializer];
    }
    
    return self;
}

- (instancetype)initWithBaseURL:(NSURL *)url {
    NSAssert(NO, @"Use either +manager or -init to instantiate a CAFactualSessionManager");
    return nil;
}

- (RACSignal *)bingImageRequestWithBarcodeObject:(CABarcodeObject *)barcodeObject {
    return [self GET:@"Image" parameters:@{@"Query" : [self buildQueryStringWithBarcodeObject:barcodeObject]}];
}

- (NSString *)buildQueryStringWithBarcodeObject:(CABarcodeObject *)barcodeObject {
    return [NSString stringWithFormat:@"'%@ %@'", barcodeObject.name, barcodeObject.brand];
}

- (NSString *)thumbnailKeyPath {
    if (!_thumbnailKeyPath) {
        _thumbnailKeyPath = @"d.results.Thumbnail.MediaUrl";
    }
    
    return _thumbnailKeyPath;
}


@end
