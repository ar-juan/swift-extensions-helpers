//
//  UITextFieldWithoutEditing.swift
//
//  Created by Arjan on 25/04/16.
//

import UIKit

/**
 `UITextFieldWithoutEditing` is a normal `UITextField`, but without the possibility of copying / selecting / pasting text.
 Only its primary input method (e.g. keyboard) is allowed.
 */
class UITextFieldWithoutEditing: UITextField {    
    override func selectionRects(for range: UITextRange) -> [Any] {
        return []
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        // Disable copy, select all, paste
        // Swift 2.3 breekt dit, weet nog niet waarom
        /*if action == #selector(NSObject.copy(_:)) || action == #selector(NSObject.selectAll(_:)) || action == #selector(NSObject.paste(_:)) {
            return false
        }*/
        // Default
        return super.canPerformAction(action, withSender: sender)
    }
}
