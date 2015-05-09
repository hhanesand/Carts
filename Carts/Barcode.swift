//
//  Barcode.swift
//  Carts
//
//  Created by Hakon Hanesand on 5/9/15.
//  Copyright (c) 2015 Hakon Hanesand. All rights reserved.

class Barcode {

    var barcode: String
    var type: String
    
    required init(barcode: String) {
        self.barcode = barcode
    }
    
    convenience init(metadataObject: AVMetadataMachineReadableCodeObject) {
        self.init(barcode: metadataObject.stringValue)
        type = metadataObject.type
    }
}
