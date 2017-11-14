//
//  VirtualObjectTableViewController.swift
//  ARKitBasics
//
//  Created by Abhinav Prakash on 09/11/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit
import SceneKit

class VirtualObjectTableViewController: UITableViewController {
    
    private let virtualObjectInstance = VirtualObjects()
    
    var virtualObjectSelectedIndexPath: Int?

    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let popoverPresentationController = navigationController?.popoverPresentationController {
            if popoverPresentationController.arrowDirection != .unknown {
                navigationItem.leftBarButtonItem = nil
            }
        }
        let size = tableView.minimumSize(forSection: 0)
        preferredContentSize = size
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return virtualObjectInstance.virtualObjectCountArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = virtualObjectInstance.virtualObjectCountArray
        let dequeued = tableView.dequeueReusableCell(withIdentifier: "Virtual Objects", for: indexPath)
        dequeued.textLabel?.text = data[indexPath.row].name
        dequeued.detailTextLabel?.text = "Click to add a \(data[indexPath.row].name)"
        
        return dequeued
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Add a visual cue to indicate that the cell was selected.
        self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        // Invoked so we can prepare for a change in selection.
        // Remove previous selection, if any.
        if let selectedIndex = self.tableView.indexPathForSelectedRow {
            // Note: Programmatically deslecting does NOT invoke tableView(:didSelectRowAt:), so no risk of infinite loop.
            self.tableView.deselectRow(at: selectedIndex, animated: false)
            // Remove the visual selection indication.
            self.tableView.cellForRow(at: selectedIndex)?.accessoryType = .none
        }
        virtualObjectSelectedIndexPath = indexPath.row
        
        return indexPath
    }
}
