//
//  CABarcodeFetchManager.swift
//  Carts
//
//  Created by Hakon Hanesand on 4/26/15.
//  Copyright (c) 2015 Hakon Hanesand. All rights reserved.
//

import UIKit

class CABarcodeFetchManager: NSObject {
    
    var factual: CAFactualSessionManager
    var bing: CABingSessionManager
    
    override required init() {
        self.factual = CAFactualSessionManager()
        self.bing = CABingSessionManager()
    }
   
    func queryForBarcode(item: CABarcode) -> PFQuery {
        return CABarcodeObject.query()!.whereKey("barcode", equalTo: item.barcode)
    }
    
    func fetchProductInformationForBarcode(barcode: CABarcode) -> RACSignal {
        let productQuery = self.queryForBarcode(barcode)
        
        return productQuery.getFirstObjectWithRACSignal().catch({ (error: NSError!) -> RACSignal! in
            return self.fetchProductInformationFromFactualForBarcode(barcode).doError({ (error: NSError!) -> Void in
                CAParseAnalytics.trackMissingBarcode(barcode)
            })
        })
    }
    
    func fetchProductInformationFromFactualForBarcode(barcode: CABarcode) -> RACSignal {
        return self.factual.queryFactualForBarcode(barcode.barcode).map({ (next: AnyObject!) -> AnyObject! in
            return CABarcodeObject(dictionary: next as! [NSObject : AnyObject])
        }).doNext({ (next: AnyObject!) -> Void in
            let object = next as! CABarcodeObject
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                self.bing.bingImageRequestWithBarcodeObject(object).subscribeNext({ (next: AnyObject!) -> Void in
                    let imageURLs = next as! Array<AnyObject>
                    object.addImageURLSFromArray(imageURLs)
                    object.saveInBackground()
                })
            })
        })
    }
}
