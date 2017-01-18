//
//  UIActivityIndicatorViewWithBackground.swift
//  SiteDish
//
//  Created by Arjan van der Laan on 18/01/17.
//  Copyright © 2017 Arjan developing. All rights reserved.
//

import UIKit

class UIActivityIndicatorViewCenteredWithBackground: UIActivityIndicatorView {

    // http://stackoverflow.com/a/26063150
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = (UIColor (white: 0.3, alpha: 0.75))
        layer.cornerRadius = 5
        self.frame = CGRect(x: 0, y: 0, width: 50.0, height: 50.0)
        self.center = superview?.center ?? CGPoint()
        activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
    }
}
