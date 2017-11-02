//
//  UIPickerViewWithButtons.swift
//  Jeeves
//
//  Created by Arjan on 25/04/16.
//  Copyright © 2016. All rights reserved.
//

import UIKit

/**
 This is a normal UIPickerView, with the only addition of two buttons on top, "Annuleren", and "Klaar" in a `toolBar` var.
 - note: Tip: Use in combination with `UITextFieldWithoutEditing` and set `toolBar` as the inputAccesoryView of a `UITextFieldWithoutEditing`, and `self`, the `UIPickerViewWithButtons`, as `inputView` of a `UITextFieldWithoutEditing`
 - requires: set the target-action of `doneButton` and `cancelButton`
 */
class UIPickerViewWithButtons: UIPickerView {
    
    /**
     Set this e.g. as the inputAccesoryView of a `UITextfield`, and `self`, the `UIPickerViewWithButtons`, as `inputView` of a UITextField
     */
    var toolBar: UIToolbar = UIToolbar()
    var cancelButton: UIBarButtonItem!
    var doneButton: UIBarButtonItem!
    
    var cancelButtonTitle = "Annuleren"
    var doneButtonTitle = "Klaar"
    
    func setup() {
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(white: 0.3, alpha: 1)
        toolBar.sizeToFit()
        
        doneButton = UIBarButtonItem(title: doneButtonTitle, style: UIBarButtonItemStyle.plain, target: self, action: #selector(UIPickerViewWithButtons.donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        cancelButton = UIBarButtonItem(title: cancelButtonTitle, style: UIBarButtonItemStyle.plain, target: self, action: #selector(UIPickerViewWithButtons.cancelPicker))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
    }
    
    @objc func cancelPicker() {
        logthis("target-action of \(#function) not implemented")
    }
    
    @objc func donePicker() {
        logthis("target-action of \(#function) not implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
}
