//
//  Barcode.swift
//  Carts
//
//  Created by Håkon Hanesand on 6/18/16.
//  Copyright © 2016 Hakon Hanesand. All rights reserved.
//

import Foundation
import AVFoundation
import RealmSwift

enum BarcodeType {

    case UPC
    case EAN13
}

class Barcode: Object {

    dynamic var barcode = ""
    dynamic var type: BarcodeType?

    required init(barcode: String) {
        self.barcode = barcode
    }

    convenience init(metadata: AVMetadataMachineReadableCodeObject) {
        self.init(barcode: metadata.stringValue)
    }
}
