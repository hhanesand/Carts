//
//  CAManualEntryView.swift
//  Carts
//
//  Created by Hakon Hanesand on 4/26/15.
//  Copyright (c) 2015 Hakon Hanesand. All rights reserved.
//

import UIKit

class CAManualEntryView: UIView, UITextFieldDelegate {
    
    var activeField: UITextField?
    
    @IBOutlet weak var name: JVFloatLabeledTextField?
    @IBOutlet weak var confirm: UIButton?
    @IBOutlet weak var cancel: UIButton?
    
    override required init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        let font = UIFont(name: "AvenirNext-Regular", size: 12)
        self.name!.floatingLabelFont = font
        self.name!.floatingLabelTextColor = UIColor.grayColor()
        self.name!.attributedPlaceholder = NSAttributedString(string: "Name", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor(), NSFontAttributeName : UIFont(name: "AvenirNext-Regular", size: 16)!])
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.activeField = textField
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.activeField = nil
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
