//
//  Objects.swift
//  ARKitBasics
//
//  Created by Abhinav Prakash on 26/11/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit
import CoreData

class Objects: NSManagedObject {

    class func findOrCreateObject(matching object: Objects, in context: NSManagedObjectContext) throws -> Objects {
        let request: NSFetchRequest<Objects> = Objects.fetchRequest()
        request.predicate = NSPredicate(format: "uniqueID = %@", object.uniqueID!)
        
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                assert(matches.count == 1, "database inconsistency")
                return matches[0]
            }
        } catch {
            throw error
        }
        
        let anObject = Objects(context: context)
        anObject.uniqueID = object.uniqueID
        anObject.name = object.name
        anObject.color = object.color
        anObject.collectedAt = object.collectedAt
        
        return anObject
    }
}
