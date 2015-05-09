//
//  RACAlamofire.swift
//  RACAlamofire
//
//  Created by Hakon Hanesand on 5/6/15.
//  Copyright (c) 2015 Hakon Hanesand. All rights reserved.

import Alamofire
import ReactiveCocoa

func request(URLRequest: URLRequestConvertible) -> Alamofire.Request {
    Manager.sharedInstance.startRequestsImmediately = false
    return Manager.sharedInstance.request(URLRequest.URLRequest)
}

public func request(method: Alamofire.Method, URLString: URLStringConvertible, parameters: [String: AnyObject]? = nil, encoding: ParameterEncoding = .URL) -> Request {
    Manager.sharedInstance.startRequestsImmediately = false
    return Manager.sharedInstance.request(method, URLString, parameters: parameters, encoding: encoding)
}

public extension Request {
    //RACAlamofire.request("google.com").responseSignal(Request.bingResponseSerializer())
    
    public func responseSignal<ReturnType>(serializer: Serializer) -> SignalProducer<ReturnType, NSError> {
        return SignalProducer { observer, disposable in
            self.response(serializer: serializer, completionHandler: { (request, response, object, error) -> Void in
                if let error = error {
                    sendError(observer, error)
                } else if let object = object as? ReturnType {
                    sendNext(observer, object)
                    sendCompleted(observer)
                }
            })
            
            self.resume()
        
            disposable.addDisposable {
                self.cancel()
            }
        }
    }
}

