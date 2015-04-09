//
//  GLBingRequestSerializer.h
//  GroceryList
//
//  Created by Hakon Hanesand on 4/8/15.
//
//

#import "AFURLRequestSerialization.h"

@interface GLBingRequestSerializer : AFHTTPRequestSerializer

/**
 *  The parameters for a Bing image search
 *  Default parameters are 
 *
 *  format : JSON
 *  top : 1
 *  adult : strict
 */
@property (nonatomic, copy) NSDictionary *parameters;

/**
 *  The base URL for a Bing Image API search
 *  Default is : https://api.datamarket.azure.com/Bing/Search/v1/Image
 */
@property (nonatomic, copy) NSString *baseURL;

/**
 *  The keypath for the image that is returned in the JSON file
 *  Default is : d.results.Thumbnail.MediaUrl
 */
@property (nonatomic, copy) NSString *thumbnailKeyPath;

- (NSMutableURLRequest *)bingRequestWithQueryString:(NSString *)query error:(NSError *__autoreleasing *)error;

@end
