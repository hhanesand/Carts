//
//  CAListTableViewController.swift
//  Carts
//
//  Created by Hakon Hanesand on 4/26/15.
//  Copyright (c) 2015 Hakon Hanesand. All rights reserved.
//

import UIKit

class CAListTableViewController: CAQueryTableViewController, UITableViewDelegate {

    var scanner: CAScannerViewController
    var user: PFUser? {
        didSet {
            self.title = self.user!.bestName()
        }
    }
    
    required init(style: UITableViewStyle) {
        scanner = CAScannerViewController.instance()
//         self.scanner.view.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
        
        super.init(style: .Plain, className: "")
        
        self.pullToRefreshEnabled = true
        self.paginationEnabled = false
        self.loadingViewEnabled = false
    }

    required init!(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let barButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "didPressAddButton")
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        self.setToolbarItems([flexibleSpace, barButton, flexibleSpace], animated: false)
        
        self.tableView.registerNib(UINib(nibName: "CATableViewCell", bundle: nil), forCellReuseIdentifier: "CATableViewCellIdentifier")
        
        self.subscribeToScannerSignal()
    }
    
    private func subscribeToScannerSignal() {
        self.scanner.listItemSignal?.takeUntil(self.rac_willDeallocSignal()).deliverOnMainThread().subscribeNext({ (next: AnyObject!) -> Void in
            let barcodeObject = next as! CABarcodeObject
            
            let existing = self.list().items.rac_sequence.objectPassingTest({ (next: AnyObject!) -> Bool in
                let object = next as! CAListItemObject
                return object.item.isEqual(barcodeObject)
            }) as? CAListItemObject
            
            if existing == nil {
                self.list().items.addObject(CAListItemObject(barcodeObject: barcodeObject))
            } else {
                existing!.quantity = Int(existing!.quantity) + 1
            }
        })
    }
    
    func list() -> CAListObject {
        return self.user!.valueForKey("list") as! CAListObject
    }
    
    func didPressAddButton() {
        self.presentViewController(self.scanner, animated: true, completion: nil)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    override func signalForTable() -> RACSignal! {
        let query = CAListObject.query()!
        query.includeKey("items.item")
        
        return query.getObjectWithIdWithSignal(PFUser.currentUser()!.list().objectId!).map {
            if let listObject = $0 as? CAListObject {
                return listObject.items
            }
            
            return nil
        }
    }
    
    override func cachedSignalForTable() -> RACSignal! {
        let query = CAListObject.query()!.includeKey("items.item").fromLocalDatastore()
        
        return query.getObjectWithIdWithSignal(PFUser.currentUser()!.list().objectId!).map {
            if let listObject = $0 as? CAListObject {
                return listObject.items
            }
            
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CATableViewCellIdentifier", forIndexPath: indexPath) as! CATableViewCell
        
        if let listItem = self.objectAtIndexPath(indexPath) as? CAListItemObject {
            cell.name.text = listItem.item.name
            cell.brand.text = listItem.item.brand
            cell.brand.text = listItem.item.category
            
            let url = NSURL(string: listItem.item.image[0] as! String)!
            let request = NSMutableURLRequest(URL: url)
            
            cell.image.setImageWithURLRequest(request, placeholderImage: nil, success: { (request, response, image) -> Void in
                cell.image.image = image;
                cell.image.setNeedsDisplay()
                }, failure: nil)
        }
        
        return cell
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if self.objects!.count == 0 {
            let noSavedBarcodesLabel = UILabel(frame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)))
            noSavedBarcodesLabel.text = "You have not saved any barcodes."
            noSavedBarcodesLabel.textColor = UIColor.blackColor()
            noSavedBarcodesLabel.numberOfLines = 0
            noSavedBarcodesLabel.textAlignment = .Center
            noSavedBarcodesLabel.font = UIFont(name: "Palatino-Italic", size: 15)
            noSavedBarcodesLabel.sizeToFit()
            
            self.tableView.backgroundView = noSavedBarcodesLabel
            self.tableView.separatorStyle = .None
            
            return 0
        } else {
            self.tableView.backgroundView = nil
            self.tableView.separatorStyle = .SingleLine
            return 1
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 71
    }
}
