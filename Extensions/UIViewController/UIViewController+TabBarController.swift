//
//  UIViewController+TabBarController.swift
//
//  Created by Arjan on 04/05/16.
//

import UIKit

extension UIViewController {
    
    /**
     `tabBarController` does not return `self` if `self` is already a `UITabBarController`.
     Which is kinda sad if you think because you never have a `UITabBarController` in another `UITabBarController`.
     Example usage: `appDelegate.window?.rootViewController?.selfOrHigherTabBarController?.DoSomething()`
     - returns `self` if you already call it a `UITabBarController`.
     */
    public var selfOrHigherTabBarController: UITabBarController? {
        get {
            if self is UITabBarController {
                return (self as! UITabBarController)
            } else {
                return self.tabBarController
            }
        }
    }
}