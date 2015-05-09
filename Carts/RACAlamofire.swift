//
//  RACAlamofire.swift
//  Carts
//
//  Created by Hakon Hanesand on 5/5/15.
//  Copyright (c) 2015 Hakon Hanesand. All rights reserved.

import Alamofire
import ReactiveCocoa

public class RACRequest: Manager {
    
    
    
    func signal() -> RACSignal {
        return RACSignal.createSignal { (subscriber) -> RACDisposable! in
            self.response { (_, _, object, _) -> Void in
                subscriber.sendNext(object)
                subscriber.sendCompleted()
            }
            
            return nil
        }
    }
}
