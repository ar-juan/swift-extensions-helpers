//
//  UIAlertController.swift
//
//  Created by Arjan on 04/04/16.
//

import UIKit

extension UIAlertController {
    
    // TODO: Moet weg, vind ik.
    func show() {
        present(animated: false, completion: nil)
    }
    
    func present(animated: Bool, completion: (() -> Void)?) {
        if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
            presentFromController(rootVC, animated: animated, completion: completion)
        }
    }
    
    fileprivate func presentFromController(_ controller: UIViewController, animated: Bool, completion: (() -> Void)?) {
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
                    controller.present(self, animated: animated, completion: completion)
                //    }
                }
            }
    }
    
    
    // Korte route
    class func alertWithTitle(_ title: String?, message: String, buttonTitle: String, buttonCompletion: ((UIAlertAction) -> Void)?) -> UIAlertController {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: buttonCompletion))
        return ac
    }
}
