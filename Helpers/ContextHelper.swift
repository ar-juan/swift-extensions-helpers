//
//  ContextHelper.swift
//
//  Created by Arjan van der Laan on 05/02/16.
//

import Foundation
import CoreData

class ContextHelper {
    static let DatabaseAvailabilityNotificationName = "DatabaseAvailabilityNotificationName"
    static let DatabaseAvailabilityContext = "DatabaseAvailabilityContext"
    
    static let sharedInstance = ContextHelper()
    private(set) var context: NSManagedObjectContext! { didSet {
            // post notification: WE HAVE THE CONTEXT
            // let everyone who might be interested know this context is available
            // this happens very early in the running of our application
            // it would make NO SENSE to listen to this radio station in a View Controller that was segued to, for example
            // (but that's okay because a segued-to View Controller would presumably be "prepared" by being given a context to work in)
            assert(NSThread.isMainThread())
            if context != nil {
                let userInfo: [String: NSManagedObjectContext] = [ContextHelper.DatabaseAvailabilityContext: context]
                NSNotificationCenter.defaultCenter().postNotificationName(ContextHelper.DatabaseAvailabilityNotificationName, object: self, userInfo: userInfo)
            }
        }
    }
    
    /**
     Asynchronously performs a block on the context's queue (main queue)
     - note: don't forget to call `performBlock(andWait)` on the `context`
    */
    func useContextWithOperation(operation: ((context: NSManagedObjectContext)->Void)) {
        //let context = self.context
        if self.context == nil && self.preparingDocument == true { // if we're currently getting / creating the database
            let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                // tehn try again in half a second
                self.useContextWithOperation(operation)
            })
        } else { // not currently preparing the context
            if self.context == nil { // but it doesnt exist yet
                // this could happen
                self.prepareDatabaseWhenDone({ (success: Bool, context: NSManagedObjectContext?) in
                    if success && context != nil { operation(context: context!) }
                    else { logthis("preparing database failed") }
                })
            } else {
                operation(context: self.context)
//                context.performBlockAndWait({ 
//                    operation(context: self.context)
//                })
            }
        }
    }
    
    private init() {} // prevents others from using the default '()' initializer for this class.
    private var preparingDocument: Bool = false
    
    func prepareDatabaseWhenDone(whenDone: ((success: Bool, context: NSManagedObjectContext?) -> Void)?) {
        guard let appName = NSBundle.mainBundle().infoDictionary![kCFBundleNameKey as String] as? String else {
            fatalError("no appname")
        }
        
        guard checkAndSetPreparingDocument() == false else { // do this only once
            logthis("trying to prepare database more than once")
            return
        }
        
        let modelName = "Model"
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        guard let modelURL = NSBundle.mainBundle().URLForResource(modelName, withExtension: "momd") else {
            fatalError("error loading NSBundle.mainBundle().URLForResource(\"\(modelName)\", withExtension: \"momd\"). Call your main model \"Model.xcdatamodeld\"")
        }
        
        guard let managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL) else {
            fatalError("cannot create mom")
        }
        
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        //Encrypted Core Data github.com/project-imas/encrypted-core-data
        //let coordinator = EncryptedStore.makeStore(managedObjectModel, passcode: "KmmWcFuq21sTie8Z3Imb8U2K9E3LR9fj4C90gWy0GFGBafU8XL2CrdoYCUcLsDssf713L4KwnUGhrJgPOpSLqiMYFmeNCLqzc4tc")
        
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        
        
        /*
        As part of the initialization of Core Data, assign the adding of the persistent store (NSPersistentStore) to the persistent store coordinator (NSPersistentStoreCoordinator) to a background queue. That action can take an unknown amount of time, and performing it on the main queue can block the user interface, possibly causing the application to terminate.
        */
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("\(appName)CoreData.sqlite")
            let failureReason = "There was an error creating or loading the application's saved data."
            do {
                let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
                try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: options)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.context = managedObjectContext
                    whenDone?(success: true, context: self.context)
                })
                self.preparingDocument = false

            } catch {
                // Report any error we got.
                var dict = [String: AnyObject]()
                dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
                dict[NSLocalizedFailureReasonErrorKey] = failureReason
                
                dict[NSUnderlyingErrorKey] = error as NSError
                let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    logthis("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
                    whenDone?(success: false, context: nil)
                })
                self.preparingDocument = false
            }
        }
    }
    
    private lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "nl.auxilium.PwcReportingApp" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    
    static let lockQueue: dispatch_queue_t = dispatch_queue_create("com.App.LockQueue", nil)
    private func checkAndSetPreparingDocument() -> Bool {
        // We need to make sure that only one process can access this property _preparingDocument at the same time:
        var result: Bool = false
        dispatch_sync(ContextHelper.lockQueue, { () -> Void in
            if !self.preparingDocument {
                self.preparingDocument = true
            } else {
                result = true
            }
        })
        return result
    }
    
    // MARK: - Core Data Saving support
    @objc func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
                //print("context saved")
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                logthis("Unresolved error saving context: \(nserror), \(nserror.userInfo)")
                return
            }
        }
    }
}