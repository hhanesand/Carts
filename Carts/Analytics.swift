//
//  Analytics.swift
//  Carts
//
//  Created by Hakon Hanesand on 5/9/15.
//  Copyright (c) 2015 Hakon Hanesand. All rights reserved.

class Analytics {
 
    static let missingBarcodeCloudFuncName = "trackMissingBarcode"
    static let missingBarcodeCloudFuncBarcodeParameter = "barcode"
    
    class func trackMissingBarcode(barcode: Barcode) {
        PFCloud.callFunctionInBackground(missingBarcodeCloudFuncName, withParameters: [missingBarcodeCloudFuncBarcodeParameter : barcode.barcode])
    }
}