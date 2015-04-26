//
//  GLRect.h
//  GroceryList
//
//  Created by Hakon Hanesand on 4/22/15.

#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>

extern CGRect GLRectMakeWithOriginSize(CGPoint origin, CGSize size);
extern CGRect GLRectMakeWithOrigin(CGPoint origin);
extern CGRect GLRectMakeWithSize(CGSize size);

extern CGRect GLRectMakeWithSizeCenteredInRect(CGSize size, CGRect rect);
extern CGSize GLSizeMin(CGSize size1, CGSize size2);