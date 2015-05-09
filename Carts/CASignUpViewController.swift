//
//  CASignUpViewController.swift
//  Carts
//
//  Created by Hakon Hanesand on 4/26/15.
//  Copyright (c) 2015 Hakon Hanesand. All rights reserved.
//

import UIKit
import Alamofire

class CASignUpViewController: UIViewController, UITextFieldDelegate {

    var delegate: CASignUpDelegate?
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var signUp: CAAuthenticationButton!
    @IBOutlet weak var facebook: CAAuthenticationButton!
    @IBOutlet weak var twitter: CAAuthenticationButton!
    
    lazy var transitionDelegate: CATransitionDelegate = {
        return CATransitionDelegate(controller: self)
    }()
    
    class func instance() -> CASignUpViewController {
        let storyboard = UIStoryboard(name: "CASignUpViewController", bundle: nil)
        return storyboard.instantiateInitialViewController() as! CASignUpViewController
    }
    
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

        self.signUp.enabled = true;
        
        self.facebook.rac_signalForControlEvents(.TouchUpInside).flattenMap { (next: AnyObject!) -> RACStream! in
            return PFFacebookUtils.logInWithSignalWithReadPermissions(["public_profile", "user_friends", "email"])
            }.catch { (error: NSError!) -> RACSignal! in
                return RACSignal.createSignal({ (sub: RACSubscriber!) -> RACDisposable! in
                self.facebook.animateError()
                    sub.sendCompleted()
                    return nil
            })
            }.subscribeNext { (next: AnyObject!) -> Void in
                let user = next as! PFUser
            self.facebook.animateSuccess()
                
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
                
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    
                }
                
                let connection = FBSDKGraphRequestConnection()
                
                let picture = FBSDKGraphRequest(graphPath: "me/picture", parameters: ["redirect" : "false"])
                let profile = FBSDKGraphRequest(graphPath: "me", parameters: nil)
                
                var done = false
                
                connection.addRequest(picture, completionHandler: { (conn: FBSDKGraphRequestConnection!, res: AnyObject!, error: NSError!) -> Void in
                    let dic = res as! NSDictionary
                    user["picture"] = dic.valueForKeyPath("data.url")
                    
                    if done {
                        user.saveInBackground()
                    } else {
                        done = true
                    }
                })
                
                connection.addRequest(profile, completionHandler: { (conn: FBSDKGraphRequestConnection!, res: AnyObject!, error: NSError!) -> Void in
                    user.bindWithFacebookGraphRequest(res as! [NSObject : AnyObject])
                    
                    if done {
                        user.saveInBackground()
                    } else {
                        done = true
                    }
                })
                
                connection.start()
        }
        
        self.twitter.rac_signalForControlEvents(.TouchUpInside).flattenMap { (next: AnyObject!) -> RACStream! in
            return PFTwitterUtils.logInWithSignal()
            }.catch { (error: NSError!) -> RACSignal! in
                return RACSignal.createSignal({ (sub: RACSubscriber!) -> RACDisposable! in
                self.twitter.animateError()
                    sub.sendCompleted()
                    return nil
            })
            }.subscribeNext { (next: AnyObject!) -> Void in
                let user = next as! PFUser
                self.twitter.animateSuccess()
                
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
                
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    
                }
                
                Alamofire.request(Twitter.UserLookup(id: PFTwitterUtils.twitter()!.userId!)).validate().responseJSON(options: .AllowFragments, completionHandler: { (_, _, userInfo, _) -> Void in
                    user.bindWithTwitterResponse(userInfo as! [String : AnyObject])
                    user.saveInBackground()
                })
        }
        
        self.signUp.rac_signalForControlEvents(.TouchUpInside).doNext { (next: AnyObject!) -> Void in
            self.view.endEditing(true)
            }.map { (next: AnyObject!) -> AnyObject! in
                let user = PFUser.currentUser()!
                user.username = self.username.text
                user.password = self.password.text
                return user
            }.flattenMap { (next: AnyObject!) -> RACStream! in
                let user = next as! PFUser
                return user.signUpInBackgroundWithSignal()
            }.catch { (error: NSError!) -> RACSignal! in
                return RACSignal.createSignal({ (sub: RACSubscriber!) -> RACDisposable! in
                    self.signUp.animateError()
                    sub.sendCompleted()
                    return nil
                })
            }.subscribeNext { (next: AnyObject!) -> Void in
                let user = next as! PFUser
                self.signUp.animateSuccess()
                
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
                
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    
                }
        }
    }
    
    @IBAction func didTapDismissButton(sender: AnyObject) {
        self.view.endEditing(true)
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func didTapInBackground(sender: AnyObject) {
        self.view.endEditing(true)
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
            self.signUp.sendActionsForControlEvents(.TouchUpInside)
        }
        
        return false
    }
}
