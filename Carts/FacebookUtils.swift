//
//  FacebookUtils.swift
//  Carts
//
//  Created by Hakon Hanesand on 5/9/15.
//  Copyright (c) 2015 Hakon Hanesand. All rights reserved.

extension PFFacebookUtils {
    
    class func logInWithSignalWithReadPermissions(permissions: [String]? = nil) -> SignalProducer<PFUser, NSError> {
        return SignalProducer { observer, disposable in
            logInInBackgroundWithReadPermissions(permissions) { user, error in
                if let error = error {
                    sendError(observer, error)
                } else {
                    sendNext(observer, user)
                    sendCompleted(observer)
                }
            }
        }
    }
}
