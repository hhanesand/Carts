//
//  CAShareCartViewController.swift
//  Carts
//
//  Created by Hakon Hanesand on 4/26/15.
//  Copyright (c) 2015 Hakon Hanesand. All rights reserved.
//

import UIKit
import Foundation

class CAShareCartViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, CAUserTableViewCellDelegate, CAKeyboardMovementResponderDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var animatableKeyboardContstaint: NSLayoutConstraint!
    
    var keyboardResponder: CAKeyboardResponderAnimator?
    lazy var transitionDelegate: CATransitionDelegate = {
        return CATransitionDelegate(controller: self)
    }()
    
    var previousSearch: String = ""
    var searchResults: Array<PFUser> = []
    
    class func instance() -> CAShareCartViewController {
        let storyboard = UIStoryboard(name: "CAShareCartViewController", bundle: nil)
        return storyboard.instantiateInitialViewController() as! CAShareCartViewController
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configureModalPresentation()
    }
    
    func configureModalPresentation() {
        self.modalPresentationStyle = .Custom
        self.transitioningDelegate = self.transitionDelegate;
        self.modalPresentationCapturesStatusBarAppearance = true
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.searchBar.becomeFirstResponder()
        
        keyboardResponder = CAKeyboardResponderAnimator(delegate: self)
        
        self.searchBar.rac_textSignal().filter { (next: AnyObject!) -> Bool in
            return self.isValidSearchString(next as! String)
            }.throttle(0.5).subscribeNext { (next: AnyObject!) -> Void in
                self.performQueryWithSearchString(next as! String)
        }
    }
    
    func isValidSearchString(string: String) -> Bool {
        return count(string) >= 2 && string != self.previousSearch
    }
    
    func performQueryWithSearchString(string: String) {
        self.previousSearch = string
        
        PFUser.query()!.whereKey("searchableID", hasPrefix: string.lowercaseString).findObjectsInbackgroundWithRACSignal().subscribeNext { (next: AnyObject!) -> Void in
            self.searchResults = next as! Array
            self.tableView.reloadData()
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResults.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CAFollowUserTableViewIdentifier", forIndexPath: indexPath) as! CAUserTableViewCell
        cell.delegate = self
        cell.bindWithUser(self.objectForIndexPath(indexPath))
        return cell
    }
    
    func userDidTapAddFriendButtonInTableViewCell(cell: CAUserTableViewCell!) {
//        println("Follow button was tapped for user with username \(self.objectForIndexPath(self.tableView.indexPathForCell(cell)).valueForKey(""))")
    }
    
    func objectForIndexPath(indexPath: NSIndexPath) -> PFUser {
        return self.searchResults[indexPath.row]
    }
    
    func viewForActiveUserInputElement() -> UIView {
        return self.footerView
    }
    
    func viewToAnimateForKeyboardAdjustment() -> UIView {
        return self.footerView
    }
    
    func layoutConstraintForAnimatingView() -> NSLayoutConstraint {
        return self.animatableKeyboardContstaint
    }
}
