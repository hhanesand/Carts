//
//  CAQueryTableViewController.swift
//  Carts
//
//  Created by Hakon Hanesand on 4/27/15.
//  Copyright (c) 2015 Hakon Hanesand. All rights reserved.

import UIKit

struct NetworkResponseKey{
    static let Cache = "kCACacheResponseKey"
    static let Network = "kCANetworkResponseKey"
}

class CAQueryTableViewController: PFQueryTableViewController {
    
    override func loadObjects(page: Int, clear: Bool) {
        assert(!self.paginationEnabled, "CAQueryTableViewController can not be used with pagination enabled.")
        
        loading = true
        objectsWillLoad()
        
        let cacheSignal = cachedSignalForTable().map {
            RACTuple(objectsFromArray: $0 as! [AnyObject])
        }
        
        let networkSignal = signalForTable().map {
            RACTuple(object $0 as! [AnyObject])
        }
        
        RACSignal.merge([cacheSignal, networkSignal]).doNext {
            let tuple = $0 as! RACTuple
        }
    }
    
    func cachedSignalForTable() -> RACSignal {
        fatalError("cachedSignalForTable() must be overriden in subclass")
    }
    
    func signalForTable() -> RACSignal {
        fatalError("signalForTable() must be overriden in subclass")
    }
}
