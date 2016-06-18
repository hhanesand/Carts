//
//  User.swift
//  Carts
//
//  Created by Håkon Hanesand on 6/18/16.
//  Copyright © 2016 Hakon Hanesand. All rights reserved.
//

import Foundation
import RealmSwift

class Person: Object {

    dynamic var name = ""

    dynamic var carts = List<Cart>()
}
