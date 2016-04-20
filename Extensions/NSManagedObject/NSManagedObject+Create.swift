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
    class func objectWithRemoteId<T: NSManagedObject>(remoteId: Int, inContext context: NSManagedObjectContext) -> T? {
        var object: T? = nil
        if remoteId > 0 {
            let request = NSFetchRequest(entityName: String(T))
            request.predicate = NSPredicate(format: "id == %d", remoteId)
            
            do
            {
                let results = try context.executeFetchRequest(request)
                if results.count > 1 { logthis("More than one \(String(T)) with same id. Should never happen") }
                else if let result = results.first as? T { object = result }
                else {
                    object = (NSEntityDescription.insertNewObjectForEntityForName(String(T), inManagedObjectContext: context) as! T)
                    object?.setValue(remoteId, forKeyPath: "id") //object!.id = remoteId
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