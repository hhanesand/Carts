//
//  Item.swift
//  Carts
//
//  Created by Håkon Hanesand on 6/18/16.
//  Copyright © 2016 Hakon Hanesand. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {

    dynamic var name = ""
    dynamic var brand: String?
    dynamic var category: String?

    let barcodes = List<Barcode>()
    let images = List<String>()
}
