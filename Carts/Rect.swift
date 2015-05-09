//  Rect.swift
//  Carts
//
//  Created by Hakon Hanesand on 5/9/15.
//  Copyright (c) 2015 Hakon Hanesand. All rights reserved.

func makeRectWithOrigin(origin: CGPoint, #size: CGSize) -> CGRect {
    return CGRect(x: origin.x, y: origin.y, width: size.width, height: size.height)
}

func makeRectWithOrigin(origin: CGPoint) -> CGRect {
    return makeRectWithOrigin(origin, size: CGSizeZero)
}

func makeRectWithSize(size: CGSize) -> CGRect {
    return makeRectWithOrigin(CGPointZero, size: size)
}

func makeRectWithSizeCenteredInRect(size: CGSize, rect: CGRect) -> CGRect {
    let center = CGPoint(x: rect.minX, y: rect.minY)
    let origin = CGPoint(x: floor(center.x - size.width / 2.0), y: floor(center.y - size.height / 2.0))
    return makeRectWithOrigin(origin, size: size)
}

func minSize(a: CGSize, b: CGSize) -> CGSize {
    return CGSize(width: min(a.width, b.width), height: min(a.height, b.height))
}