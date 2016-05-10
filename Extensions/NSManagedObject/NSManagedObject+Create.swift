//
//  NSManagedObject+Create.swift
//
//  Created by Arjan on 20/04/16.
//

import Foundation
import CoreData

extension NSManagedObject {
    
    // stackoverflow.com/questions/27109268/how-can-i-create-instances-of-managed-object-subclasses-in-a-nsmanagedobject-swi
    convenience init(context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName(String(self.dynamicType), inManagedObjectContext: context)!
        self.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    // stackoverflow.com/questions/25271208/cast-to-typeofself
    class func objectWithId<T where T: NSManagedObject>(id: Int, inContext context: NSManagedObjectContext) -> T? {
        var object: T?
        if id > 0 {
            let request = NSFetchRequest(entityName: String(self))
            request.predicate = NSPredicate(format: "id == %d", id)
            
            do
            {
                let results = try context.executeFetchRequest(request)
                if results.count > 1 { logthis("More than one \(String(self)) with same id. Should never happen") }
                else if let result = results.first as? NSManagedObject { object = result as? T }
                else {
                    object = (NSEntityDescription.insertNewObjectForEntityForName(String(self), inManagedObjectContext: context) as! T)
                    object?.setValue(id, forKeyPath: "id")
                }
            }
            catch let error as NSError
            {
                logthis("\(error.localizedDescription) (\(error.localizedFailureReason))")
            }
        }
        return object
    }
    
    // stackoverflow.com/questions/25271208/cast-to-typeofself
    class func existingObjectWithId<T where T: NSManagedObject>(id: Int, inContext context: NSManagedObjectContext, createNewIfNil: Bool) -> T? {
        var object: T?
        if id > 0 {
            let request = NSFetchRequest(entityName: String(self))
            request.predicate = NSPredicate(format: "id == %d", id)
            
            do
            {
                let results = try context.executeFetchRequest(request)
                if results.count > 1 { logthis("More than one \(String(self)) with same id. Should never happen") }
                else if let result = results.first as? NSManagedObject { object = result as? T }
                else if createNewIfNil == true {
                    object = (NSEntityDescription.insertNewObjectForEntityForName(String(self), inManagedObjectContext: context) as! T)
                    object?.setValue(id, forKeyPath: "id")
                }
            }
            catch let error as NSError
            {
                logthis("\(error.localizedDescription) (\(error.localizedFailureReason))")
            }
        }
        return object
    }
    
    
    class func nextNSNumberIntForField(field: String, context: NSManagedObjectContext) -> NSNumber? {
        var nextNumber: NSNumber? = nil
        
        let request = NSFetchRequest(entityName: String(self))
        request.sortDescriptors = [NSSortDescriptor(key: field, ascending: true)]
        
        do
        {
            let results = try context.executeFetchRequest(request)
            if results.count == 0 {
                nextNumber = 1
            } else {

                let last = results.last as! NSManagedObject
                
                guard let lastNumber = last.valueForKeyPath(field) as? NSNumber else {
                    logthis("\(field) is not a NSNumber (wrong input) or is nil (model integrity compromised)")
                    return nil
                }
                nextNumber = lastNumber.integerValue + 1
            }
        }
        catch let error as NSError
        {
            logthis("\(error.localizedDescription) (\(error.localizedFailureReason))")
        }
        
        return nextNumber
    }
}