//
//  IntrinsicContentTableView.swift
//  SiteDish
//
//  Created by Arjan van der Laan on 20-11-17.
//  Copyright © 2017 Arjan developing. All rights reserved.
//

import UIKit

class IntrinsicContentTableView: UITableView {
    
    override var contentSize:CGSize {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    
    override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        return CGSize(width: UIViewNoIntrinsicMetric, height: contentSize.height)
    }
    
}
