//
//  ContextHelper.swift
//
//  Created by Arjan van der Laan on 05/02/16.
//  Usage is free for everyone, but no one can claim ownership.
//

import Foundation
import CoreData

class ContextHelper {
    static let DatabaseAvailabilityNotificationName = "DatabaseAvailabilityNotificationName"
    static let DatabaseAvailabilityContext = "DatabaseAvailabilityContext"
    
    static let sharedInstance = ContextHelper()
    fileprivate(set) var context: NSManagedObjectContext! { didSet {
            // post notification: WE HAVE THE CONTEXT
            // let everyone who might be interested know this context is available
            // this happens very early in the running of our application
            // it would make NO SENSE to listen to this radio station in a View Controller that was segued to, for example
            // (but that's okay because a segued-to View Controller would presumably be "prepared" by being given a context to work in)
            assert(Thread.isMainThread)
            if context != nil {
                let userInfo: [String: NSManagedObjectContext] = [ContextHelper.DatabaseAvailabilityContext: context]
                NotificationCenter.default.post(name: Notification.Name(rawValue: ContextHelper.DatabaseAvailabilityNotificationName), object: self, userInfo: userInfo)
            }
        }
    }
    
    /**
     Asynchronously performs a block on the context's queue (main queue)
     - note: don't forget to call `performBlock(andWait)` on the `context`
    */
    func useContextWithOperation(_ operation: @escaping ((_ context: NSManagedObjectContext)->Void)) {
        //let context = self.context
        if self.context == nil && self.preparingDocument == true { // if we're currently getting / creating the database
            let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
                // tehn try again in half a second
                self.useContextWithOperation(operation)
            })
        } else { // not currently preparing the context
            if self.context == nil { // but it doesnt exist yet
                // this could happen
                self.prepareDatabaseWhenDone({ (success: Bool, context: NSManagedObjectContext?) in
                    if success && context != nil { operation(context!) }
                    else { logthis("preparing database failed") }
                })
            } else {
                operation(self.context)
//                context.performBlockAndWait({ 
//                    operation(context: self.context)
//                })
            }
        }
    }
    
    fileprivate init() {} // prevents others from using the default '()' initializer for this class.
    fileprivate var preparingDocument: Bool = false
    
    func prepareDatabaseWhenDone(_ whenDone: ((_ success: Bool, _ context: NSManagedObjectContext?) -> Void)?) {
        guard let appName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as? String else {
            fatalError("no appname")
        }
        
        guard checkAndSetPreparingDocument() == false else { // do this only once
            logthis("trying to prepare database more than once")
            return
        }
        
        let modelName = "Model"
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd") else {
            fatalError("error loading NSBundle.mainBundle().URLForResource(\"\(modelName)\", withExtension: \"momd\"). Call your main model \"Model.xcdatamodeld\"")
        }
        
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("cannot create mom")
        }
        
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        //Encrypted Core Data github.com/project-imas/encrypted-core-data
        //let coordinator = EncryptedStore.makeStore(managedObjectModel, passcode: "KmmWcFuq21sTie8Z3Imb8U2K9E3LR9fj4C90gWy0GFGBafU8XL2CrdoYCUcLsDssf713L4KwnUGhrJgPOpSLqiMYFmeNCLqzc4tc")
        
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        
        
        /*
        As part of the initialization of Core Data, assign the adding of the persistent store (NSPersistentStore) to the persistent store coordinator (NSPersistentStoreCoordinator) to a background queue. That action can take an unknown amount of time, and performing it on the main queue can block the user interface, possibly causing the application to terminate.
        */
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            let url = self.applicationDocumentsDirectory.appendingPathComponent("\(appName)CoreData.sqlite")
            let failureReason = "There was an error creating or loading the application's saved data."
            do {
                let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
                try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
                
                if #available(iOS 9.0, *) {
                    managedObjectContext.shouldDeleteInaccessibleFaults = true
                }
                
                DispatchQueue.main.async(execute: { () -> Void in
                    self.context = managedObjectContext
                    whenDone?(true, self.context)
                })
                self.preparingDocument = false

            } catch {
                // Report any error we got.
                var dict = [String: AnyObject]()
                dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
                dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
                
                dict[NSUnderlyingErrorKey] = error as NSError
                let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
                
                DispatchQueue.main.async(execute: { () -> Void in
                    logthis("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
                    whenDone?(false, nil)
                })
                self.preparingDocument = false
            }
        }
    }
    
    fileprivate lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "%%%bundle identifier%%%" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    
    static let lockQueue: DispatchQueue = DispatchQueue(label: "com.App.LockQueue", attributes: [])
    fileprivate func checkAndSetPreparingDocument() -> Bool {
        // We need to make sure that only one process can access this property _preparingDocument at the same time:
        var result: Bool = false
        ContextHelper.lockQueue.sync(execute: { () -> Void in
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
