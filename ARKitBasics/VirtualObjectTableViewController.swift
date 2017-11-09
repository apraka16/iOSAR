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

    private var virtualObjectCollection = ["Cube", "Sphere", "Custom", "Happy"]
    
    var virtualObjectSelected = ""
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return virtualObjectCollection.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = virtualObjectCollection[indexPath.row]
        let dequeued = tableView.dequeueReusableCell(withIdentifier: "Virtual Objects", for: indexPath)
        dequeued.textLabel?.text = data
        dequeued.detailTextLabel?.text = "Click to add"
        
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
        
        virtualObjectSelected = virtualObjectCollection[indexPath.row]
        
        return indexPath
    }
}
