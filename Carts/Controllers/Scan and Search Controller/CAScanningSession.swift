//
//  CAScanningSession.swift
//  Carts
//
//  Created by Hakon Hanesand on 4/26/15.
//  Copyright (c) 2015 Hakon Hanesand. All rights reserved.
//

import UIKit
import AVFoundation

extension Array {
    
    private func all(matching: Element -> Bool) -> Bool {
        return self.map(matching).reduce(true) { $0 && $1 }
    }
}

class CAScanningSession: NSObject, AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
//    var captureDevice: AVCaptureDevice?
    
    var connection: AVCaptureConnection?
    var paused: Bool
    
    var recievedImage: UIImage?
    
    var barcodeSignal: SignalProducer<String, NSError>
    
    var captureSession: AVCaptureSession!
    
    class func session() -> CAScanningSession {
        return CAScanningSession()
    }
    
    override required init() {
        paused = true
        
        super.init()
        
        setupBarcodeSignal()
        initializeCaptureSession()
    }
    
    func setupBarcodeSignal() {
        let barcodeSelectorSignal = self.rac_signalForSelector(#selector(AVCaptureMetadataOutputObjectsDelegate.captureOutput(_:didOutputMetadataObjects:fromConnection:)), fromProtocol: "AVCaptureMetadataOutputObjectsDelegate" as! Protocol).toSignalProducer().map { return $0 as! RACTuple }
        
        barcodeSignal = barcodeSelectorSignal.filter {
            let metadataObjects = $0.second as! [AVMetadataObject]
            let barcodeMetadataObjects = metadataObjects.filter { $0.isKindOfClass(AVMetadataMachineReadableCodeObject) }
            return !self.paused && barcodeMetadataObjects.count > 0
        }.logEvents().map { test in
            // TODO - Return barcode created from AVMetadataMachineReadableCodeObject
            return ""
        }
    }
    
    func start() {
        if self.captureSession!.running {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                self.captureSession!.startRunning()
            })
        }
    }
    
    func stop() {
        if self.captureSession!.running {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                self.captureSession!.stopRunning()
            })
        }
    }
    
    private func initializeCaptureSession() {        
        self.captureSession = AVCaptureSession()
        self.captureSession.sessionPreset = AVCaptureSessionPresetPhoto
    
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        if let videoInput = try? AVCaptureDeviceInput(device: captureDevice) {
            self.captureSession.addInput(videoInput)
            let videoOutput = AVCaptureVideoDataOutput()
            self.captureSession.addOutput(videoOutput)
            
            videoOutput.videoSettings = [Int(kCVPixelFormatType_32BGRA) : kCVPixelBufferPixelFormatTypeKey]
            videoOutput.setSampleBufferDelegate(self, queue: dispatch_queue_create("dispatch"))
            
            let metadataOutput = AVCaptureMetadataOutput()
            metadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
            self.captureSession?.addOutput(metadataOutput)
            
            metadataOutput.metadataObjectTypes = metadataOutput.availableMetadataObjectTypes
        } else {
            fatalError("Failed to initialize video.")
        }
        
    }
    
    func captureImageFromVideoOutput() {
//        self.connection.enabled = YES; //start the output of frames and after recieving one
//        
//        //observe the recievedImage property for changes
//        return [[RACObserve(self, recievedImage) skip:1] take:1];
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didDropSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
//        self.connection = connection;
//        connection.enabled = NO;
//        
//        //set the recieved image property so observers can fire signals
//        self.recievedImage = [UIImage imageFromSampleBuffer:sampleBuffer];
    }
}
