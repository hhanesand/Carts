//
//  ResultBridge.swift
//  Carts
//
//  Created by Hakon Hanesand on 6/14/16.
//  Copyright © 2016 Hakon Hanesand. All rights reserved.
//

import enum Result.Result
import Alamofire
import Foundation

extension Result {
    
    func bridge() -> Alamofire.Result<T, Error> {
        switch self {
        case .Success(let value):
            return Alamofire.Result.Success(value)
        case .Failure(let error):
            return Alamofire.Result.Failure(error)
        }
    }
    
}

extension Result where T : Optional<T> {
    
    func optionalMap<U>(@noescape transform: Value -> U) -> Result<U, Error>? {
        if value != nil {
            return map(transform)
        }
    }
}