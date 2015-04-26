//
//  GLBingSessionManager.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/9/15.

#import <ReactiveCocoa/ReactiveCocoa.h>

#import "GLBingSessionManager.h"
#import "GLBarcodeObject.h"
#import "GLBingRequestSerializer.h"
#import "GLBingResponseSerializer.h"

NSString * const kGLBingURL = @"https://api.datamarket.azure.com/Bing/Search/v1/";

@interface GLBingSessionManager ()
@property (nonatomic) NSString *thumbnailKeyPath;
@end

@implementation GLBingSessionManager

+ (instancetype)manager {
    return [[GLBingSessionManager alloc] init];
}

- (instancetype)init {
    if (self = [super initWithBaseURL:[NSURL URLWithString:kGLBingURL]]) {
        self.requestSerializer = [GLBingRequestSerializer serializer];
        self.responseSerializer = [GLBingResponseSerializer serializer];
    }
    
    return self;
}

- (instancetype)initWithBaseURL:(NSURL *)url {
    NSAssert(NO, @"Use either +manager or -init to instantiate a GLFactualSessionManager");
    return nil;
}

- (RACSignal *)bingImageRequestWithBarcodeObject:(GLBarcodeObject *)barcodeObject {
    return [self GET:@"Image" parameters:@{@"Query" : [self buildQueryStringWithBarcodeObject:barcodeObject]}];
}

- (NSString *)buildQueryStringWithBarcodeObject:(GLBarcodeObject *)barcodeObject {
    return [NSString stringWithFormat:@"'%@ %@'", barcodeObject.name, barcodeObject.brand];
}

- (NSString *)thumbnailKeyPath {
    if (!_thumbnailKeyPath) {
        _thumbnailKeyPath = @"d.results.Thumbnail.MediaUrl";
    }
    
    return _thumbnailKeyPath;
}


@end
