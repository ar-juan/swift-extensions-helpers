//
//  UITextFieldWithoutEditing.swift
//  Jeeves
//
//  Created by Arjan on 25/04/16.
//  Copyright © 2016 Auxilium. All rights reserved.
//

import UIKit

/**
 `UITextFieldWithoutEditing` is a normal `UITextField`, but without the possibility of copying / selecting / pasting text.
 Only its primary input method (e.g. keyboard) is allowed.
 */
class UITextFieldWithoutEditing: UITextField {    
    override func selectionRectsForRange(range: UITextRange) -> [AnyObject] {
        return []
    }
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        // Disable copy, select all, paste
        if action == #selector(NSObject.copy(_:)) || action == #selector(NSObject.selectAll(_:)) || action == #selector(NSObject.paste(_:)) {
            return false
        }
        // Default
        return super.canPerformAction(action, withSender: sender)
    }
}
