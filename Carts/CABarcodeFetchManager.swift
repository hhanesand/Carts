//
//  CABarcodeFetchManager.swift
//  Carts
//
//  Created by Hakon Hanesand on 4/26/15.
//  Copyright (c) 2015 Hakon Hanesand. All rights reserved.

import UIKit
import Alamofire

class CABarcodeFetchManager: NSObject {
    
//    func queryForBarcode(item: CABarcode) -> PFQuery {
//        return CABarcodeObject.query()!.whereKey("barcode", equalTo: item.barcode)
//    }
    
//    func fetchProductInformationForBarcode(barcode: CABarcode) -> RACSignal {
//        let productQuery = self.queryForBarcode(barcode)
//        
//        return productQuery.getFirstObjectWithRACSignal().catch({ (error: NSError!) -> RACSignal! in
//            Alamofire.request(Factual.SearchBarcode(barcode: barcode.barcode)).validate().responseBarcode(
//        })
//    }
    
//    func fetchProductInformationFromFactualForBarcode(barcode: CABarcode) -> RACSignal {
//        return self.factual.queryFactualForBarcode(barcode.barcode).map({ (next: AnyObject!) -> AnyObject! in
//            return CABarcodeObject(dictionary: next as! [NSObject : AnyObject])
//        }).doNext({ (next: AnyObject!) -> Void in
//            let object = next as! CABarcodeObject
//            
//            
//        })
//    }
}
