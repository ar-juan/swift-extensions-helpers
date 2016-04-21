//
//  NSManagedObject+Create.swift
//  Jeeves
//
//  Created by Arjan on 20/04/16.
//  Copyright © 2016 Auxilium. All rights reserved.
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
    class func objectWithRemoteId<T where T: NSManagedObject>(remoteId: Int, inContext context: NSManagedObjectContext) -> T? {
        var object: T?
        if remoteId > 0 {
            let request = NSFetchRequest(entityName: String(self))
            request.predicate = NSPredicate(format: "id == %d", remoteId)
            
            do
            {
                let results = try context.executeFetchRequest(request)
                if results.count > 1 { logthis("More than one \(String(self)) with same id. Should never happen") }
                else if let result = results.first as? NSManagedObject { object = result as? T }
                else {
                    object = (NSEntityDescription.insertNewObjectForEntityForName(String(self), inManagedObjectContext: context) as! T)
                    object?.setValue(remoteId, forKeyPath: "id")
                }
            }
            catch let error as NSError
            {
                logthis("\(error.localizedDescription) (\(error.localizedFailureReason))")
            }
        }
        return object
    }
}