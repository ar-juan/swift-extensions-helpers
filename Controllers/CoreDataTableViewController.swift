//
//  CoreDataTableViewController.swift
//
//  Created by Arjan on 08/04/16.
//

import UIKit
import CoreData


class CoreDataTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var debug: Bool = false
    //var managedObjectContext: NSManagedObjectContext? = nil    
    
    // MARK: - Table View Datasource & Delegate methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        if debug { print("number of sections: \(self.fetchedResultsController?.sections?.count ?? 0)") }
        return self.fetchedResultsController?.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController?.sections![section]
        if debug { print("\(sectionInfo?.numberOfObjects ?? 0) rows in section \(section)") }
        
        return sectionInfo?.numberOfObjects ?? 0
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.fetchedResultsController?.sections![section].name
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return self.fetchedResultsController?.section(forSectionIndexTitle: title, at: index) ?? 0
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.fetchedResultsController?.sectionIndexTitles
    }
    
    
    // MARK: - Fetched results controller
    func performFetch() {
        if self.fetchedResultsController?.fetchRequest.predicate != nil {
            if self.debug { print("\(String(describing: type(of: self))).\(#function) fetching \(String(describing: self.fetchedResultsController?.fetchRequest.entityName)) with predicate: \(String(describing: self.fetchedResultsController?.fetchRequest.predicate))") }
        } else {
            if self.debug { print("\(String(describing: type(of: self))).\(#function) fetching all \(String(describing: self.fetchedResultsController?.fetchRequest.entityName)) (i.e. no predicate)") }
        }
        do
        {
            try self.fetchedResultsController?.performFetch()
        }
        catch let error as NSError {
            print("\(String(describing: type(of: self))).\(#function) performFetch: failed")
            print("\(String(describing: type(of: self))).\(#function) \(error.localizedDescription) (\(String(describing: error.localizedFailureReason)))")
        }
        self.tableView.reloadData()
    }
    
    private var warned: Bool = false
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? {
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
                    if self.debug { print("\(String(describing: type(of: self))).\(#function) \(oldfrc != nil ? "updated" : "set")") }
                    self.performFetch()
                } else {
                    if self.debug { print("\(String(describing: type(of: self))).\(#function) reset to nil") }
                    self.tableView.reloadData()
                }
            }
        }
    }
    var _fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? = nil
    
    
    // MARK: - NSFetchedResultsControllerDelegate
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case NSFetchedResultsChangeType(rawValue: 0)!:
            //logthis("iOS 8 bug - Do nothing if we get an invalid change type.")
            break;
        case .insert:
            self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case NSFetchedResultsChangeType(rawValue: 0)!:
            //logthis("iOS 8 bug - Do nothing if we get an invalid change type.")
            break;
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        //self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, withObject: anObject as! NSManagedObject)
        case .move:
            // Fixes a bug where indexPath == newIndexPath:
            // Which gives error: Attempt to create two animations for cell with userInfo (null)
            // similar to stackoverflow.com/questions/31383760/ which has more solutions
            if indexPath != newIndexPath {
                tableView.moveRow(at: indexPath!, to: newIndexPath!)
            }
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }

}
