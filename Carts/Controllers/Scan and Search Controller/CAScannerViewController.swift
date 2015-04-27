//
//  CAScannerViewController.swift
//  Carts
//
//  Created by Hakon Hanesand on 4/26/15.
//  Copyright (c) 2015 Hakon Hanesand. All rights reserved.
//

import UIKit

class CAScannerViewController: CABaseViewController, CADismissableHandlerDelegate, CAKeyboardMovementResponderDelegate, UITableViewDelegate, UITableViewDataSource, UIViewControllerTransitioningDelegate, UITextFieldDelegate {

    @IBOutlet weak var manualEntryView: CAManualEntryView!
    @IBOutlet weak var manualLayoutBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchView: UIVisualEffectView!
    @IBOutlet weak var videoPreviewView: CAVideoPreviewView!
    
    var listItemSignal: RACSignal?
    
    lazy var transitionDelegate: CATransitionDelegate = {
        return CATransitionDelegate(controller: self)
    }()
 
    lazy var manualEntryViewDismissHandler: CADismissableViewHandler = {
        return CADismissableViewHandler(animateableView: self.manualEntryView, superviewHeight: CGRectGetHeight(self.view.frame), animateableConstraint: self.manualLayoutBottomConstraint)
    }()
    
    var responder: CAKeyboardResponderAnimator?
    var barcodeManager: CABarcodeFetchManager
    var barcodeScanner: CAScanningSession
    var targetingReticule: CACameraLayer?
    
    class func instance() -> CAScannerViewController {
        let storyboard = UIStoryboard(name: "CAScannerViewController", bundle: nil)
        return storyboard.instantiateInitialViewController() as! CAScannerViewController
    }
    
    required init(coder aDecoder: NSCoder) {
        barcodeScanner = CAScanningSession()
        barcodeManager = CABarcodeFetchManager()
        
        super.init(coder: aDecoder)
        
        responder = CAKeyboardResponderAnimator(delegate: self)
        
        self.configureModalPresentation()
    }
    
    func configureModalPresentation() {
        self.modalPresentationStyle = .Custom
        self.transitioningDelegate = self.transitionDelegate
        self.modalPresentationCapturesStatusBarAppearance = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeVideoPreviewLayer()
        self.initializeManualEntryView()
        self.subscribeToBarcodeScannerOutput()
    }
    
    func initializeVideoPreviewLayer() {
        self.videoPreviewView.doneScanningItemsButton.rac_command = RACCommand(signalBlock: { (next: AnyObject!) -> RACSignal! in
            self.barcodeScanner.resume()
            return self.animationStack.popAllAnimation();
        })
        
        let layer = AVCaptureVideoPreviewLayer(session: self.barcodeScanner.captureSession)
        layer.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.videoPreviewView.capturePreviewLayer = layer
    }
    
    func initializeManualEntryView() {
        self.manualEntryView.name?.rac_textSignal().map({ (next: AnyObject!) -> AnyObject! in
            let string = next as! String
            return count(string) >= 1
        }).subscribeNext({ (next: AnyObject!) -> Void in
            self.manualEntryView.confirm?.enabled = next as! Bool
        })
        
        let swipeDownToDismiss = UIPanGestureRecognizer(target: self.manualEntryViewDismissHandler, action: "handlePan:")
        self.view.addGestureRecognizer(swipeDownToDismiss)
        swipeDownToDismiss.delegate = self.manualEntryViewDismissHandler
        
        self.manualEntryViewDismissHandler.delegate = self
    }
    
    func subscribeToBarcodeScannerOutput() {
        self.listItemSignal = self.barcodeScanner.barcodeSignal?.doNext({ (next: AnyObject!) -> Void in
            CAProgressHUD.show()
            self.barcodeScanner.pause()
        }).flattenMap({ (next: AnyObject!) -> RACStream! in
            return self.barcodeManager.fetchProductInformationForBarcode(next as! CABarcode).catch({ (error: NSError!) -> RACSignal! in
                self.displayManualEntryView()
                
                let confirm = self.manualEntryView.confirm?.rac_signalForControlEvents(.TouchUpInside).map({ (next: AnyObject!) -> AnyObject! in
                    return CABarcodeObject(name: self.manualEntryView.name!.text)
                })
                
                let cancel = self.manualEntryView.cancel?.rac_signalForControlEvents(.TouchUpInside).map({ (next: AnyObject!) -> AnyObject! in
                    return nil
                })
                
                return RACSignal.merge([confirm!, cancel!]).take(1).doNext({ (next: AnyObject!) -> Void in
                    self.dismissManualEntryView()
                }).filter({ (next: AnyObject!) -> Bool in
                    return next != nil
                })
            })
        }).doNext({ (next: AnyObject!) -> Void in
            let barcode = next as! CABarcodeObject
            CAProgressHUD.showSuccessWithStatus("Added \(barcode.name)")
            self.barcodeScanner.resume()
        }).logNext()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.updateCameraReticule()
    }
    
    func updateCameraReticule() {
        self.targetingReticule?.removeFromSuperlayer()
        
        let bounds = self.view.bounds
        let sideLength = CGRectGetWidth(bounds) * 0.5
        let cameraRect = CGRectMake(CGRectGetMidX(bounds) - sideLength * 0.5, CGRectGetMidY(bounds) - sideLength * 0.5, sideLength, sideLength)
        
        self.targetingReticule = CACameraLayer(bounds: cameraRect, cornerRadius: 10, lineLength: 4)
        self.view.layer.addSublayer(self.targetingReticule)
        self.targetingReticule?.opacity = 0
    }
    
    func displayManualEntryView() {
        CAProgressHUD.showErrorWithStatus("Item not found - Please enter")
        self.manualEntryViewDismissHandler.presentViewWithVelocity(0)
    }
    
    func dismissManualEntryView() -> RACSignal {
        self.barcodeScanner.resume()
        
        return self.manualEntryViewDismissHandler.dismissViewWithVelocity(0).doCompleted({ () -> Void in
            self.manualEntryView.removeFromSuperview()
        })
    }
    
    func willDismissViewAfterUserInteraction() {
        self.barcodeScanner.resume()
        self.view.endEditing(true)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCellWithIdentifier("SearchItem", forIndexPath: indexPath) as! UITableViewCell
    }
    
    @IBAction func didTapDoneButton(sender: UIButton) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func didTapScanningButton(sender: UIButton) {
        let scale = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY)
        scale.fromValue = NSValue(CGPoint: CGPointMake(1, 1))
        scale.toValue = NSValue(CGPoint: CGPointMake(2, 2))
        scale.springSpeed = 12
        scale.springBounciness = 0
        scale.name = "scaleSearchViewLayer"
        
        let fade = POPSpringAnimation(propertyNamed: kPOPLayerOpacity)
        fade.fromValue = 1
        fade.toValue = 0
        fade.springSpeed = 10
        fade.springBounciness = 0
        fade.name = "fadeSearchViewLayer"
        
        let show = POPSpringAnimation(propertyNamed:kPOPLayerOpacity)
        show.fromValue = 0
        show.toValue = 1.0
        show.springSpeed = 10
        show.springBounciness = 0
        show.name = "showTargetingReticule"
        
        let show1 = POPSpringAnimation(propertyNamed:kPOPViewAlpha)
        show1.fromValue = 0
        show1.toValue = 1
        show1.springSpeed = 10
        show1.springBounciness = 0
        show1.name = "showButton"
        
        self.animationStack.pushAnimation(scale, targetObject: self.searchView.layer, description: "scale")
        self.animationStack.pushAnimation(fade, targetObject: self.searchView.layer, description: "scale")
        self.animationStack.pushAnimation(show, targetObject: self.targetingReticule!, description: "scale")
        self.animationStack.pushAnimation(show1, targetObject: self.videoPreviewView.doneScanningItemsButton, description: "scale")
    }
    
    func viewToAnimateForKeyboardAdjustment() -> UIView {
        return self.manualEntryView
    }
    
    func viewForActiveUserInputElement() -> UIView {
        return self.manualEntryView.activeField!
    }
    
    func layoutConstraintForAnimatingView() -> NSLayoutConstraint {
        return self.manualLayoutBottomConstraint
    }
}
