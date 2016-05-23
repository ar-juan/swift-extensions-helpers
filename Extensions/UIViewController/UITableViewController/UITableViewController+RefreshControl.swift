//
//  UITableViewController+RefreshControl.swift
//

import UIKit

extension UITableViewController {
    
    /**
     This function makes sure the UITableViewController scrolls down a bit so that the UIRefreshControl is visible.
     `control!.beginRefreshing()` does not automatically do this, so we have to do it manually.
     
     - note: if `control` is `nil` nothing happens
     */
    func beginRefreshing(control: UIRefreshControl?) {
        if control != nil {
            self.tableView.setContentOffset(CGPoint(x: 0, y: self.tableView.contentOffset.y-control!.frame.size.height), animated: true)
            control!.beginRefreshing()
        }
    }
    /**
     This function makes sure the UITableViewController scrolls up to it's original position
     `control!.endRefreshing()` does not automatically do this in all cases,
     so we have to do it manually to make sure it happens.
     
     - note: if `control` is `nil` nothing happens
     */
    func endRefreshing(control: UIRefreshControl?) {
        if control != nil {
            control!.endRefreshing()
            self.tableView.setContentOffset(CGPointZero, animated: true)
        }
    }
}
