//
//  CAListOverviewTableViewController.swift
//  Carts
//
//  Created by Hakon Hanesand on 4/26/15.
//  Copyright (c) 2015 Hakon Hanesand. All rights reserved.
//

import Foundation

class CAListOverviewTableViewController: CAQueryTableViewController {
    
    @IBOutlet var navigationBarLabel: UILabel!
    @IBOutlet var footerView: UIView!
    var listTableViewController : CAListTableViewController?
    var shareTableViewController : CAShareCartViewController?
    
    class func instance() -> CAListTableViewController {
        let storyboard = UIStoryboard(name: "CAListOverviewTableViewController", bundle: nil)
        return storyboard.instantiateInitialViewController() as! CAListTableViewController
    }
    
    required init(coder aDecoder: NSCoder!) {
        let startTime = CACurrentMediaTime()
        
        super.init(coder: aDecoder)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> () in
            println("Started loading Storyboards after \(CACurrentMediaTime() - startTime)")
            self.listTableViewController = CAListTableViewController(style: .Plain)
            self.shareTableViewController = CAShareCartViewController.instance()
            println("Finished loading Storyboards after \(CACurrentMediaTime() - startTime)")
        })
        
        self.paginationEnabled = false
        self.loadingViewEnabled = false
        self.pullToRefreshEnabled = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        let barButton = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "didTapShareCartButton")
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        self.setToolbarItems([flexibleSpace, barButton, flexibleSpace], animated: false)
        
        if let navigationBar = self.navigationController?.navigationBar,
            let navigationItem = self.navigationController?.navigationItem {
            navigationBar.barTintColor = UIColor(red: 0.000, green: 0.843, blue: 0.699, alpha: 1.000)
            navigationBar.barStyle = .Black
            navigationBar.tintColor = UIColor.whiteColor()
            
            navigationItem.titleView = self.navigationBarLabel
                self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: navigationItem.backBarButtonItem!.style, target: nil, action: nil)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.navigationController?.setToolbarHidden(false, animated: false)
        self.footerView.frame = self.navigationController!.toolbar.bounds;
    }
    
    func test() -> Bool {
        return true
    }
    
    func didTapShareCartButton() {
        if PFUser.isLoggedIn() {
            self.presentViewController(self.shareTableViewController!, animated: true, completion: nil)
        } else {
            let signUpController = CASignUpViewController.instance()
            self.presentViewController(signUpController, animated: true, completion: nil)
        }
    }
    
    override func cachedSignalForTable() -> RACSignal! {
        return PFUser.currentUser()!.relationForKey("following").query()!.fromLocalDatastore().findObjectsInbackgroundWithRACSignal()
    }
    
    override func signalForTable() -> RACSignal! {
        if PFAnonymousUtils.isLinkedWithUser(PFUser.currentUser()) {
            return RACSignal.empty()
        }
        
        return PFUser.currentUser()!.relationForKey("following").query()!.findObjectsInbackgroundWithRACSignal()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CAListTableViewController", forIndexPath: indexPath) as! CAListOverviewTableViewCell
        
        if let user = self.objectAtIndexPath(indexPath) as? PFUser {
            let url = NSURL(string: user.valueForKey("picture") as! String)!
            let request = NSMutableURLRequest(URL: url)
            
            cell.image.setImageWithURLRequest(request, placeholderImage: nil, success: { (request, response, image) -> Void in
                cell.image.image = image;
                cell.image.setNeedsDisplay()
                }, failure: nil)
        }
    
        return cell
    }
    
    override func objectAtIndexPath(indexPath: NSIndexPath?) -> PFObject? {
        if indexPath!.row == 0 {
            return PFUser.currentUser()
        } else {
            return super.objectAtIndexPath(NSIndexPath(forRow: indexPath!.row - 1, inSection: indexPath!.section))
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return super.numberOfSectionsInTableView(tableView) + 1;
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100.0;
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.listTableViewController?.user = self.objectAtIndexPath(indexPath) as? PFUser
        self.navigationController?.pushViewController(self.listTableViewController!, animated: true)
    }
}