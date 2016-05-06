//
//  PresentingSegue.swift
//
//  Created by Arjan on 18/11/15.
//

import UIKit

class PresentingSegue: UIStoryboardSegue {
    
    override func perform() {
        sourceViewController.presentViewController(self.destinationViewController, animated: false, completion: nil)
    }

 //   [[self sourceViewController] presentViewController:[self destinationViewController] animated:NO completion:nil];

    
}
