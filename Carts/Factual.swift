//
//  Factual.swift
//  Carts
//
//  Created by Hakon Hanesand on 5/4/15.
//  Copyright (c) 2015 Hakon Hanesand. All rights reserved.

import Alamofire
import SwiftyJSON

enum Factual: URLRequestConvertible {
    
    static let baseURL = "http://api.v3.factual.com/t/"

    case SearchBarcode(barcode: String)
    
    var method: Alamofire.Method {
        switch self {
        case SearchBarcode(let barcode):
            return .GET
        }
    }
    
    var URLRequest: NSURLRequest {
        let (path: String, parameters: [String : AnyObject]) = {
            switch self {
            case SearchBarcode(let barcode):
                return ("products-cpg", ["q" : barcode])
            }
        }()
        
        let URL = NSURL(string: Factual.baseURL)!
        let factualURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
        factualURLRequest.HTTPMethod = method.rawValue
        
        //client id n5md5zTCv67RV2ctEQKrhK2cAzggCqs3khynDhKT
        //client token Utn7HYXJ77lW3fTYMFiB9Zvu0GjT1AInnjeqYFct
        
        return factualURLRequest
    }
}

extension Request {
    
    
    //Alamofire.request(Factual.searchBarcode("12312312123").validate().responseBarcode()
    
    public func barcodeSerializer(request: NSURLRequest, response: NSHTTPURLResponse?, data: NSData?) -> Serializer {
        return
    }
    
    //possibly a solution?
    let barcodeSerializer: Serializer = { (request, reponse, data) in
        let json = JSON(data: data!, options: .AllowFragments)
        
        if let itemInformation = json[0]["response"]["data"].dictionary {
            return (Request.processFactualItemInformation(itemInformation), nil)
        } else {
            return (nil, json[0]["response"]["data"].error)
        }
    }
    
    public func responseBarcode(completionHandler: (NSURLRequest, NSHTTPURLResponse?, CABarcodeObject?, NSError?) -> Void) -> Self {
        return response(serializer: Request.barcodeSerializer) { (request, response, object, error) -> Void in
            completionHandler(request, response, object as? CABarcodeObject, error)
        }
    }
    
    private static func processFactualItemInformation(json: [String : JSON]) -> CABarcodeObject {
        let barcodeObject = CABarcodeObject()
        barcodeObject.brand = json["brand"]?.string
//        barcodeObject.barcodes = make list that ignores nils here ("ean13", "upc", "upc_13")
        barcodeObject.category = json["category"]?.string
        barcodeObject.manufacturer = json["manufacturer"]?.string
        barcodeObject.name = json["product_name"]?.string
//        barcodeObject.image = json["image_urls"]?.arrayObject
        return barcodeObject
    }
}