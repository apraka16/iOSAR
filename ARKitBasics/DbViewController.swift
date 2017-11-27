//
//  DbViewController.swift
//  ARKitBasics
//
//  Created by Abhinav Prakash on 27/11/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit
import SceneKit
import CoreData

class DbViewController: ViewController {
    
    let container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer

    override func insertObject(_ newObject: SCNNode) {
        super.insertObject(newObject)
        updateDatabase(with: newObject)
        
    }
    
    private func updateDatabase(with object: SCNNode) {
        
        container?.performBackgroundTask { [weak self] context in
            _ = Object.createObject(matching: object, in: context)
            try? context.save()
            self?.printDatabaseStatistics()
        }
    }
    
    private func printDatabaseStatistics() {
        if let context = container?.viewContext {
            context.perform {
                Object.fetchObjectCount(in: context)
                Object.fetchAllObjects(in: context)
                Session.fetchSessionCount(in: context)
                Session.fetchAllSessions(in: context)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "Test Segue Identifier" {
            if let navigationViewController = segue.destination as? UINavigationController {
                if let TestVC = navigationViewController.visibleViewController as? TestTableViewController {
                    TestVC.container = container
                }
            }
//            if let TestVC = segue.destination as? TestTableViewController {
//                TestVC.container = container
//            }
        }
    }
    
}
