//
//  CARect.h
//  GroceryList
//
//  Created by Hakon Hanesand on 4/22/15.

#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>

extern CGRect CARectMakeWithOriginSize(CGPoint origin, CGSize size);
extern CGRect CARectMakeWithOrigin(CGPoint origin);
extern CGRect CARectMakeWithSize(CGSize size);

extern CGRect CARectMakeWithSizeCenteredInRect(CGSize size, CGRect rect);
extern CGSize CASizeMin(CGSize size1, CGSize size2);