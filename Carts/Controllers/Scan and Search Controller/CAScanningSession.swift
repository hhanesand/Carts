//
//  CAScanningSession.swift
//  Carts
//
//  Created by Hakon Hanesand on 4/26/15.
//  Copyright (c) 2015 Hakon Hanesand. All rights reserved.
//

import UIKit
import AVFoundation

class CAScanningSession: NSObject, AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
//    var captureDevice: AVCaptureDevice?
    
    var connection: AVCaptureConnection?
    var paused: Bool
    
    var recievedImage: UIImage?
    
    var barcodeSignal: RACSignal?
    
    var captureSession: AVCaptureSession?
    
    class func session() -> CAScanningSession {
        return CAScanningSession()
    }
    
    override required init() {
        paused = true
        
        super.init()
        
        self.setupBarcodeSignal()
        self.initializeCaptureSession()
    }
    
    func setupBarcodeSignal() {
        let barcodeSelectorSignal = self.rac_signalForSelector(Selector("captureOutput:didOutputMetadataObjects:fromConnection:"), fromProtocol: "AVCaptureMetadataOutputObjectsDelegate" as! Protocol)
        
        self.barcodeSignal = barcodeSelectorSignal.filter({ (next: AnyObject!) -> Bool in
            let value = next as! RACTuple
            let array = value.second as! Array<AVMetadataMachineReadableCodeObject>
            return !self.paused && array[0].isKindOfClass(AVMetadataMachineReadableCodeObject)
        }).bufferWithTime(0.5, onScheduler: RACScheduler.currentScheduler()).map({ (next: AnyObject!) -> AnyObject! in
            let buffer = next as! RACTuple
            let firstSelectorTuple = buffer.first as! RACTuple
            let barcodeMetadataObjects = firstSelectorTuple.second as! Array<AVMetadataMachineReadableCodeObject>
            return CABarcode(metadataObject: barcodeMetadataObjects[0])
        }).logNext().filter({ (next: AnyObject!) -> Bool in
            return !self.paused
        })
    }
    
    func resume() {
        self.paused = true
    }
    
    func pause() {
        self.paused = false
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
        self.captureSession!.sessionPreset = AVCaptureSessionPresetPhoto
        
        var error = NSError?()
        
        if let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo),
                videoInput = AVCaptureDeviceInput(device: captureDevice, error: &error) {
                    self.captureSession?.addInput(videoInput)
                    let videoOutput = AVCaptureVideoDataOutput()
                    self.captureSession?.addOutput(videoOutput)
                    
                    videoOutput.videoSettings = [kCVPixelFormatType_32BGRA : kCVPixelBufferPixelFormatTypeKey]
                    videoOutput.setSampleBufferDelegate(self, queue: dispatch_queue_create("dispatch", 0))
            
                    let metadataOutput = AVCaptureMetadataOutput()
                    metadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
                    self.captureSession?.addOutput(metadataOutput)
                    
                    metadataOutput.metadataObjectTypes = metadataOutput.availableMetadataObjectTypes
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
