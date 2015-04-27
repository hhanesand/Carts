//
//  CAFactualRequestSerializer.h
//  GroceryList
//
//  Created by Hakon Hanesand on 2/19/15.

#import <AFOAuth1/KDURLRequestSerialization+OAuth.h>

/**
 *  Serialize requests made to Factual so they conform with their OAuth specifications (http://developer.factual.com/throttling-limits/)
 */
@interface CAFactualRequestSerializer : KDHTTPRequestSerializer

@end
