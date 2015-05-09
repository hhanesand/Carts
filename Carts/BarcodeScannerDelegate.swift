//  BarcodeScannerDelegate.swift
//  Carts
//
//  Created by Hakon Hanesand on 5/9/15.
//  Copyright (c) 2015 Hakon Hanesand. All rights reserved.

@objc protocol BarcodeScannerDelegate {
    optional func scannerDidRecieveBarcode(scanner: CAScanningSession, barcode: Barcode)
}