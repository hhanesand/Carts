//
//  CAFactualResponseSerializer.h
//  GroceryList
//
//  Created by Hakon Hanesand on 2/20/15.

#import <AFNetworking/AFURLResponseSerialization.h>

/**
 *  Serializes responses from Factual (http://developer.factual.com/api-docs/#Read) and turn them into NSDictionaries
 *  If Factual returns an empty JSON file, transform it into an error
 */
@interface CAFactualResponseSerializer : AFJSONResponseSerializer

@end