//
//  Object.swift
//  ARKitBasics
//
//  Created by Abhinav Prakash on 27/11/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit
import CoreData
import SceneKit

class Object: NSManagedObject {

    class func createObject(matching node: SCNNode, in context: NSManagedObjectContext) -> Object {
        
        let anObject = Object(context: context)
        anObject.collectedAt = Date(timeIntervalSinceReferenceDate: Date.timeIntervalSinceReferenceDate)
        anObject.name = node.name
        anObject.color = nodeColorToString(of: node)
        anObject.type = "geometry"
        anObject.sessions = Session.createSession(with: "123456", in: context)
        
        return anObject
    }
    
    static func fetchObjectCount(in context: NSManagedObjectContext) {
        let request: NSFetchRequest<Object> = Object.fetchRequest()
        if let objectCount = (try? context.fetch(request))?.count {
            print("\(objectCount) - Count of objects")
        }
    }
    
    static func fetchAllObjects(in context: NSManagedObjectContext) {
        let request: NSFetchRequest<Object> = Object.fetchRequest()
        if let objects = (try? context.fetch(request)) {
            for object in objects {
                print("Name: \(object.name), Color: \(object.color), Type: \(object.type), Collected At: \(object.collectedAt), Sessions: \(object.sessions)")
            }
        }
    }
    
    static func deleteAllObjects(in context: NSManagedObjectContext) {
        let request: NSFetchRequest<Object> = Object.fetchRequest()
        if let objects = (try? context.fetch(request)) {
            for object in objects {
                context.delete(object)
            }
        }
    }
    
    class func nodeColorToString(of node: SCNNode) -> String {
        let colorOfObject = ColorOfObjects()
        
        var colorString = ""
        let color = node.childNodes.last?.geometry?.firstMaterial?.emission.contents as! UIColor
        switch color {
        case colorOfObject.UIColorFromRGB(rgbValue: colorOfObject.blueColor):
            colorString = "blue"
        case colorOfObject.UIColorFromRGB(rgbValue: colorOfObject.greenColor):
            colorString = "green"
        case colorOfObject.UIColorFromRGB(rgbValue: colorOfObject.redColor):
            colorString = "red"
        default:
            break
        }
        return colorString
    }
}
