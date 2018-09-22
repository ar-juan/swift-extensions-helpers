//
//  UIViewController.swift
//
//  Created by Arjan van der Laan on 02/02/16.
//

import UIKit

extension UIViewController {
    /**
     Searches through the view hierarchy of all the `views`, looking for *UIButtons* and *UILabels*.
     If it finds one, it applies the custom UIFont as returned by `UIFont.AppFont.FromTextStyle(String)`
     
     **Warning**: This function works only if `UIFont.AppFont.FromTextStyle(String)` is defined, which should take a dynamic iOS font (Body, Headline, Subheadline, etc) and return a UIFont with the same characteristc but a specific, possibly different, font family.
     
     - Parameter views: The views to look through (including it's subviews, recursively).
     
     - Returns: `void`
     */
    func setAppFontForViews(_ views: [UIView]) {
        for view in views {
            if view.subviews.count > 0 {
                setAppFontForViews(view.subviews)
            } else {
                if let label: UILabel = view as? UILabel {
                    label.font = label.font.appFontOfSameStyleAndSize()
                }
                else if let button: UIButton = view as? UIButton {
                    button.titleLabel?.font = button.titleLabel?.font.appFontOfSameStyleAndSize()
                }
            }
        }
    }
}
