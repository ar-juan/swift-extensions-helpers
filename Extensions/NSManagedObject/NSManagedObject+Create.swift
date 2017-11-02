//
//  NSManagedObject+Create.swift
//
//  Created by Arjan on 20/04/16.
//

import Foundation
import CoreData

extension NSManagedObject {
    
    // stackoverflow.com/questions/27109268/how-can-i-create-instances-of-managed-object-subclasses-in-a-nsmanagedobject-swi
//    convenience init(context: NSManagedObjectContext) {
//        let entity = NSEntityDescription.entityForName(String(self.dynamicType), inManagedObjectContext: context)!
//        self.init(entity: entity, insertIntoManagedObjectContext: context)
//    }
    
    // http://stackoverflow.com/questions/39660427/support-multiple-ios-sdk-versions-with-swift
    convenience init(sContext: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: String(describing: type(of: self)), in: sContext)!
        self.init(entity: entity, insertInto: sContext)
    }
    
    // stackoverflow.com/questions/25271208/cast-to-typeofself
    class func objectWithId<T>(_ id: Int, inContext context: NSManagedObjectContext) -> T? where T: NSManagedObject {
        var object: T?
        if id > 0 {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: self))
            request.predicate = NSPredicate(format: "id == %d", id)
            
            do
            {
                let results = try context.fetch(request)
                if results.count > 1 { logthis("More than one \(String(describing: self)) with same id. Should never happen") }
                else if let result = results.first as? NSManagedObject { object = result as? T }
                else {
                    object = (NSEntityDescription.insertNewObject(forEntityName: String(describing: self), into: context) as! T)
                    object?.setValue(id, forKeyPath: "id")
                }
            }
            catch let error as NSError
            {
                logthis("\(error.localizedDescription) (\(String(describing: error.localizedFailureReason)))")
            }
        }
        return object
    }
    
    // stackoverflow.com/questions/25271208/cast-to-typeofself
    class func existingObjectWithId<T>(_ id: Int, inContext context: NSManagedObjectContext, createNewIfNil: Bool) -> T? where T: NSManagedObject {
        var object: T?
        if id > 0 {
            //let request: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T> // swift 3 / ios 10
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: self)) // swift 2
            request.predicate = NSPredicate(format: "id == %d", id)
            
            do
            {
                let results = try context.fetch(request)
                if results.count > 1 { logthis("More than one \(String(describing: self)) with same id. Should never happen") }
                else if let result = results.first as? NSManagedObject { object = result as? T }
                else if createNewIfNil == true {
                    object = (NSEntityDescription.insertNewObject(forEntityName: String(describing: self), into: context) as! T)
                    object?.setValue(id, forKeyPath: "id")
                }
            }
            catch let error as NSError
            {
                logthis("\(error.localizedDescription) (\(String(describing: error.localizedFailureReason)))")
            }
        }
        return object
    }
    
    
    class func nextNSNumberIntForField(_ field: String, context: NSManagedObjectContext) -> NSNumber? {
        var nextNumber: NSNumber? = nil
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: self))
        request.sortDescriptors = [NSSortDescriptor(key: field, ascending: true)]
        
        do
        {
            let results = try context.fetch(request)
            if results.count == 0 {
                nextNumber = 1
            } else {

                let last = results.last as! NSManagedObject
                
                guard let lastNumber = last.value(forKeyPath: field) as? NSNumber else {
                    logthis("\(field) is not a NSNumber (wrong input) or is nil (model integrity compromised)")
                    return nil
                }
                nextNumber = lastNumber.intValue + 1 as NSNumber
            }
        }
        catch let error as NSError
        {
            logthis("\(error.localizedDescription) (\(String(describing: error.localizedFailureReason)))")
        }
        
        return nextNumber
    }
}
