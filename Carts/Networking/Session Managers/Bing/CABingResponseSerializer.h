//
//  CABingResponseSerializer.h
//  GroceryList
//
//  Created by Hakon Hanesand on 4/9/15.

#import "AFURLResponseSerialization.h"

/**
 *  Serializes responses from the Bing Search API, either extracting the image URLS from the JSON, or sending back an error if the required data is not present
 */
@interface CABingResponseSerializer : AFJSONResponseSerializer

@end
