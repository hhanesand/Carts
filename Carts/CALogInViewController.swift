//
//  CALogInViewController.swift
//  Carts
//
//  Created by Hakon Hanesand on 4/26/15.
//  Copyright (c) 2015 Hakon Hanesand. All rights reserved.
//

import UIKit

class CALogInViewController: UIViewController, UITextFieldDelegate {
    
    var delegate: CASignUpDelegate?
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!

    @IBOutlet weak var logIn: CAAuthenticationButton!
    
    lazy var transitionDelegate: CATransitionDelegate = {
        return CATransitionDelegate(controller: self)
    }()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configureModalPresentation()
    }
    
    func configureModalPresentation() {
        self.modalPresentationStyle = .Custom
        self.transitioningDelegate = self.transitionDelegate
        self.modalPresentationCapturesStatusBarAppearance = true
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.username.rac_textSignal().zipWith(self.password.rac_textSignal()).reduceEach { () -> AnyObject! in
//            let username = a as! String
//            let password = b as! String
//            return count(username) > 4 && count(password) > 4
//            }.subscribeNext { (next: AnyObject!) -> Void in
//            
//        }
        
//        self.logIn.rac_signalForControlEvents(.TouchUpInside).flattenMap { (next: AnyObject!) -> RACStream! in
//            return PFUser.logInInBackgroundWithUsername(self.username.text, password: self.password.text)
//            }.catch { (error: NSError!) -> RACSignal! in
//                return RACSignal.createSignal({ (subscriber: RACSubscriber!) -> RACDisposable! in
//                    subscriber.sendCompleted()
//                    return nil
//                })
//        }.subscribeCompleted { () -> Void in
//            println("Successful signup")
//        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.username.setMaskToRoundedCorners(.TopRight | .TopLeft, withRadii: 4.0)
        self.password.setMaskToRoundedCorners(.BottomRight | .BottomLeft, withRadii: 4.0)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.username {
            self.password.becomeFirstResponder()
        } else if textField == self.password {
            textField.resignFirstResponder()
            self.logIn.sendActionsForControlEvents(.TouchUpInside)
        }
        
        return false
    }
    
    @IBAction func didTapDismissButton(sender: AnyObject) {
        self.view.endEditing(true)
        self.presentedViewController!.dismissViewControllerAnimated(true, completion: nil)
        self.presentedViewController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func didTapInBackgound(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
}
