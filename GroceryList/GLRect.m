//
//  GLRect.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/22/15.

#import "GLRect.h"

CGRect GLRectMakeWithOriginSize(CGPoint origin, CGSize size) {
    return CGRectMake(origin.x, origin.y, size.width, size.height);
}

CGRect GLRectMakeWithOrigin(CGPoint origin) {
    return GLRectMakeWithOriginSize(origin, CGSizeZero);
}

CGRect GLRectMakeWithSize(CGSize size) {
    return GLRectMakeWithOriginSize(CGPointZero, size);
}

CGRect GLRectMakeWithSizeCenteredInRect(CGSize size, CGRect rect) {
    CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    CGPoint origin = CGPointMake(floorf(center.x - size.width / 2.0f),
                                 floorf(center.y - size.height / 2.0f));
    return GLRectMakeWithOriginSize(origin, size);
}

CGSize GLSizeMin(CGSize size1, CGSize size2) {
    CGSize size = CGSizeZero;
    size.width = MIN(size1.width, size2.width);
    size.height = MIN(size1.height, size2.height);
    return size;
}
