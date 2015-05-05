//
//  Twitter.swift
//  Carts
//
//  Created by Hakon Hanesand on 5/3/15.
//  Copyright (c) 2015 Hakon Hanesand. All rights reserved.

import Alamofire

enum Twitter: URLRequestConvertible {
    
    static let baseURL = "https://api.twitter.com/1.1/"
    
    case UserLookup(id: String)
    
    var method: Alamofire.Method {
        switch self {
        case UserLookup:
            return .GET
        }
    }
    
    var URLRequest: NSURLRequest {
        let (path: String, parameters: [String : AnyObject]) = {
            switch self {
            case UserLookup(let id):
                return ("users/show.json", ["user_id" : id])
            }
        }()
        
        let URL = NSURL(string: Twitter.baseURL)!
        let twitterURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
        twitterURLRequest.HTTPMethod = method.rawValue
        
        PFTwitterUtils.twitter()?.signRequest(twitterURLRequest)
        
        return Alamofire.ParameterEncoding.URL.encode(twitterURLRequest, parameters: parameters).0
    }
}