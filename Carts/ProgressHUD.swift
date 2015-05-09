//
//  ProgressHUD.swift
//  Carts
//
//  Created by Hakon Hanesand on 5/9/15.
//  Copyright (c) 2015 Hakon Hanesand. All rights reserved.

class ProgressHUD: SVProgressHUD {
    
    override class func show() {
        dispatch_async(dispatch_get_main_queue()) {
            super.show()
        }
    }
    
    override class func showSuccessWithStatus(status: String) {
        dispatch_async(dispatch_get_main_queue()) {
            super.showSuccessWithStatus(status)
        }
    }
    
    override class func showErrorWithStatus(status: String) {
        dispatch_async(dispatch_get_main_queue()) {
            super.showErrorWithStatus(status)
        }
    }
}
