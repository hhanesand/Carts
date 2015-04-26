//
//  NSDictionary+GLCustomKVOOperators.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/9/15.
//
//

#import "NSDictionary+GLCustomKVOOperators.h"

@implementation NSDictionary (GLCustomKVOOperators)

- (id)_firstForKeyPath:(NSString *)keypath {
    id array = [self valueForKeyPath:keypath];
    
    if ([array respondsToSelector:@selector(count)] && [array respondsToSelector:@selector(objectAtIndex:)]) {
        return [array objectAtIndex:0];
    }
    
    return nil;
}

@end