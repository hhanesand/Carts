//
//  Bing.swift
//  Carts
//
//  Created by Hakon Hanesand on 5/3/15.
//  Copyright (c) 2015 Hakon Hanesand. All rights reserved.

import Alamofire
import SwiftyJSON

enum Bing: URLRequestConvertible {
    
    case ImageSearch(query: String)
    
    static let baseURL = "https://api.datamarket.azure.com/Bing/Search/v1/"
    static let thumbnailPictureJSONKeypath = "d.results.Thumbnail.MediaUrl"
    static let bingAPIKey = "4RmJ+kjMTCXg36g0LmPrDTiLgF3Xb3EqJjBGwzqXC9A"
    
    var method: Alamofire.Method {
        switch self {
        case ImageSearch:
            return .GET
        }
    }
    
    var URLRequest: NSURLRequest {
        let (path: String, parameters: [String : AnyObject]) = {
            switch self {
            case ImageSearch(let query):
                return ("Image", ["q" : query, "$Format" : "JSON", "$top" : "1", "Adult" : "strict"])
            }
        }()
        
        let URL = NSURL(string: Bing.baseURL)!
        let bingRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
        bingRequest.HTTPMethod = method.rawValue
        
        let inputAuthString = "\(Bing.bingAPIKey):\(Bing.bingAPIKey)"
        let authData = inputAuthString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        let outputAuthString = "Basic \(authData.base64EncodedStringWithOptions(nil))"
        
        bingRequest.setValue(outputAuthString, forHTTPHeaderField: "Authorization")
        
        return Alamofire.ParameterEncoding.URL.encode(bingRequest, parameters: parameters).0
    }
}

extension Request {
    
    class func BingResponseSerializer() -> Serializer {
        return { (request, response, data) in
            let json = JSON(data: data!, options: .AllowFragments)
            
            if let url = json[Bing.thumbnailPictureJSONKeypath].string {
                return (url, nil)
            } else {
                return (nil, json[Bing.thumbnailPictureJSONKeypath].error)
            }
        }
    }
    
    public func reponseBingImageThumbnail(completionHandler: (NSURLRequest, NSHTTPURLResponse?, String?, NSError?) -> Void) -> Self {
        return response(serializer: Request.BingResponseSerializer()) { (request, response, object, error) -> Void in
            completionHandler(request, response, object as? String, error)
        }
    }
}
