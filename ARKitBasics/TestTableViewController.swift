//
//  TestTableViewController.swift
//  ARKitBasics
//
//  Created by Abhinav Prakash on 27/11/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit
import CoreData

class TestTableViewController: FetchedResultsTableViewController {
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true)
    }
    
    var container: NSPersistentContainer? =
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer {
        didSet { updateUI() } }
    
    var fetchedResultsController: NSFetchedResultsController<Object>?
    
    private func updateUI() {
        if let context = container?.viewContext {
            let request: NSFetchRequest<Object> = Object.fetchRequest()
            request.sortDescriptors = []
            
            fetchedResultsController = NSFetchedResultsController<Object>(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
//            fetchedResultsController?.delegate = self
            try? fetchedResultsController?.performFetch()
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Object DB Cell", for: indexPath)
        if let object = fetchedResultsController?.object(at: indexPath) {
            cell.textLabel?.text = object.name
            cell.detailTextLabel?.text = object.color
        }
        
        return cell
    }

    
}
