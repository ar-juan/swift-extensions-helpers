//
//  CoreDataTableViewController.swift
//  Jeeves
//
//  Created by Arjan on 08/04/16.
//  Copyright © 2016 Auxilium. All rights reserved.
//

import UIKit
import CoreData

class CoreDataTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    var debug: Bool = false
    //var managedObjectContext: NSManagedObjectContext? = nil    
    
    // MARK: - Table View Datasource & Delegate methods
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if debug { print("number of sections: \(self.fetchedResultsController?.sections?.count ?? 0)") }
        return self.fetchedResultsController?.sections?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController?.sections![section]
        if debug { print("\(sectionInfo?.numberOfObjects ?? 0) rows in section \(section)") }
        
        return sectionInfo?.numberOfObjects ?? 0
        
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.fetchedResultsController?.sections![section].name
    }
    
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return self.fetchedResultsController?.sectionForSectionIndexTitle(title, atIndex: index) ?? 0
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return self.fetchedResultsController?.sectionIndexTitles
    }
    
    
    // MARK: - Fetched results controller
    func performFetch() {
        if self.fetchedResultsController?.fetchRequest.predicate != nil {
            if self.debug { print("\(String(self.dynamicType)).\(#function) fetching \(self.fetchedResultsController?.fetchRequest.entityName) with predicate: \(self.fetchedResultsController?.fetchRequest.predicate)") }
        } else {
            if self.debug { print("\(String(self.dynamicType)).\(#function) fetching all \(self.fetchedResultsController?.fetchRequest.entityName) (i.e. no predicate)") }
        }
        do
        {
            try self.fetchedResultsController?.performFetch()
        }
        catch let error as NSError {
            print("\(String(self.dynamicType)).\(#function) performFetch: failed")
            print("\(String(self.dynamicType)).\(#function) \(error.localizedDescription) (\(error.localizedFailureReason))")
        }
        self.tableView.reloadData()
    }
    
    private var warned: Bool = false
    var fetchedResultsController: NSFetchedResultsController? {
        get {
            if _fetchedResultsController == nil && !warned {
                //logthis("Note: Subclass must setup fetchedResultsController. Ignore this warning if you set it up later in the view controller life cycle")
                //warned = true
            }
            return _fetchedResultsController
            
        }
        set(newfrc) {
            let oldfrc = _fetchedResultsController
            if newfrc != oldfrc {
                _fetchedResultsController = newfrc
                newfrc?.delegate = self
                if ((self.title == nil || self.title == oldfrc?.fetchRequest.entity?.name) && (self.navigationController == nil || self.navigationController?.title == nil)) {
                    self.title = newfrc?.fetchRequest.entity?.name
                }
                if newfrc != nil {
                    if self.debug { print("\(String(self.dynamicType)).\(#function) \(oldfrc != nil ? "updated" : "set")") }
                    self.performFetch()
                } else {
                    if self.debug { print("\(String(self.dynamicType)).\(#function) reset to nil") }
                    self.tableView.reloadData()
                }
            }
        }
    }
    var _fetchedResultsController: NSFetchedResultsController? = nil
    
    
    // MARK: - NSFetchedResultsControllerDelegate
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case NSFetchedResultsChangeType(rawValue: 0)!:
            //logthis("iOS 8 bug - Do nothing if we get an invalid change type.")
            break;
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case NSFetchedResultsChangeType(rawValue: 0)!:
            //logthis("iOS 8 bug - Do nothing if we get an invalid change type.")
            break;
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            //self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, withObject: anObject as! NSManagedObject)
        case .Move:
            tableView.moveRowAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }

}
