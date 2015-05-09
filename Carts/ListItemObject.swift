//  ListItemObject.swift
//  Carts
//
//  Created by Hakon Hanesand on 5/9/15.
//  Copyright (c) 2015 Hakon Hanesand. All rights reserved.

class ListItemObject: PFObject, PFSubclassing {
    
    @NSManaged var item: BarcodeObject
    @NSManaged var quantity: Int
    
    required init(barcodeObject: BarcodeObject) {
        item = barcodeObject
        quantity = 1
    }
    
    override class func parseClassName() -> String {
        return "listItem"
    }
}
