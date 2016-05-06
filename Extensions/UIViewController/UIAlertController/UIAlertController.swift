//
//  UIAlertController.swift
//
//  Created by Arjan on 04/04/16.
//

import UIKit

extension UIAlertController {
    
    func show() {
        present(animated: false, completion: nil)
    }
    
    func present(animated animated: Bool, completion: (() -> Void)?) {
        if let rootVC = UIApplication.sharedApplication().keyWindow?.rootViewController {
            presentFromController(rootVC, animated: animated, completion: completion)
        }
    }
    
    private func presentFromController(controller: UIViewController, animated: Bool, completion: (() -> Void)?) {
        if let navVC = controller as? UINavigationController,
            let visibleVC = navVC.visibleViewController {
            presentFromController(visibleVC, animated: animated, completion: completion)
        } else
            if let tabVC = controller as? UITabBarController,
                let selectedVC = tabVC.selectedViewController {
                presentFromController(selectedVC, animated: animated, completion: completion)
            }
            else
            {
                if controller.view.window != nil { // if controller is on screen
                //NSOperationQueue.mainQueue().addOperationWithBlock {
                    controller.presentViewController(self, animated: animated, completion: completion)
                //    }
                }
            }
    }
}