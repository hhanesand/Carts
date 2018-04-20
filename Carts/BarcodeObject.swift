//
//  BarcodeObject.swift
//  Carts
//
//  Created by Hakon Hanesand on 5/9/15.
//  Copyright (c) 2015 Hakon Hanesand. All rights reserved.

class BarcodeObject: PFObject, PFSubclassing {
    
    @NSManaged var name: String
    @NSManaged var brand: String
    @NSManaged var category: String
    @NSManaged var manufacturer: String
    @NSManaged var barcodes: [String]?
    @NSManaged var image: [String]?
    
    var firstBarcode: String? {
        return barcodes![0]
    }

    override class func parseClassName() -> String {
        return "item"
    }
    
    required init(dictionary: [String : AnyObject]) {
        for (key, value) in dictionary {
            setObject(value, forKey: key)
        }
    }
    
    convenience init(barcode: Barcode) {
        self.init(["barcodes" : [barocde.barcode]]) //types later?
    }
    
    convenience init(name: String) {
        self.init(dictionary: ["name" : name])
    }
    
    func addImageURLsFrom(Array array: [String]) {
        if let image = image {
            self.image += image
        } else {
            self.image = array
        }
    }
}
