//
//  UIColor.swift
//  PwcReportingApp
//
//  Created by Arjan on 26/01/16.
//  Copyright © 2016 Auxilium. All rights reserved.
//

import UIKit

extension UIColor {
    
    /**
     Shorter UIColor initialization by omitting the opacity, and requesting an Int between
     0 - 255 as parameters instead of a CGFloat between 0.0 and 1.0
     
     - Parameter red: a Int number between 0 and 255
     - Parameter green: a Int number between 0 and 255
     - Parameter blue: a Int number between 0 and 255
     
     - Returns: a UIColor instance
     */
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}