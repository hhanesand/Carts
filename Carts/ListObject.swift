//  ListObject.swift
//  Carts
//
//  Created by Hakon Hanesand on 5/9/15.
//  Copyright (c) 2015 Hakon Hanesand. All rights reserved.

class ListObject: PFObject, PFSubclassing {

    @NSManaged var items: [ListItemObject]
    
    required init() {
        items = []
        super.init()
    }
    
    override class func parseClassName() -> String {
        return "list"
    }
}
