//
//  Cart.swift
//  Carts
//
//  Created by Håkon Hanesand on 6/18/16.
//  Copyright © 2016 Hakon Hanesand. All rights reserved.
//

import Foundation
import RealmSwift

class CartItem: Object {

    dynamic var item: Item?
    dynamic var count: Int
}

class Cart: Object {

    dynamic var items = List<CartItem>()

    let owners: LinkingObjects(fromType: Person.self, property: "carts")
}
