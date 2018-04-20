//
//  Factual.swift
//  Carts
//
//  Created by Hakon Hanesand on 5/4/15.
//  Copyright (c) 2015 Hakon Hanesand. All rights reserved.

import Alamofire
import SwiftyJSON

enum FactualRouter: URLRequestConvertible {
    
    static let baseURL = "http://api.v3.factual.com/t/"

    case SearchBarcode(barcode: String)
    
    var method: Alamofire.Method {
        switch self {
        case SearchBarcode:
            return .GET
        }
    }
    
    var URLRequest: NSMutableURLRequest {
        let result: (path: String, parameters: [String : AnyObject]) = {
            switch self {
            case SearchBarcode(let barcode):
                return ("products-cpg", ["q" : barcode])
            }
        }()
        
        let URL = NSURL(string: FactualRouter.baseURL)!
        let factualURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(result.path))
        factualURLRequest.HTTPMethod = method.rawValue
        
        //client id n5md5zTCv67RV2ctEQKrhK2cAzggCqs3khynDhKT
        //client token Utn7HYXJ77lW3fTYMFiB9Zvu0GjT1AInnjeqYFct
        
        return factualURLRequest
    }
}