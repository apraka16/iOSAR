//
//  VirtualObjectTableViewController.swift
//  ARKitBasics
//
//  Created by Abhinav Prakash on 09/11/17.
//  Copyright © 2017 Apple. All rights reserved.


import UIKit
import SceneKit

class VirtualObjectTableViewController: UITableViewController, ColorObjectToVCDelegate {
    
    private let virtualObjectInstance = VirtualObjects()
    
    var virtualObjectSelectedIndexPath: Int?
    var colorChoice: UIColor?
    
    private var colorOfObjects = ColorOfObjects()
    
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return virtualObjectInstance.virtualObjectsNames.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = virtualObjectInstance.virtualObjectCount
        tableView.rowHeight = 117.0
        let dequeued = tableView.dequeueReusableCell(withIdentifier: "Virtual Objects", for: indexPath)
        let cell = dequeued as? VirtualObjectTableViewCell
        
        cell?.objectTitle.text = data[indexPath.row].name
        
        // * //
        // The following code should be made modular and node addition should be shifted elsewhere
        cell?.objectView.scene = SCNScene()

        let node = virtualObjectInstance.createNodes(from: data[indexPath.row].name, with: colorOfObjects.UIColorFromRGB(rgbValue: colorOfObjects.blueColor))
        
        // Create and add a camera to the scene
        let cameraNode = SCNNode(); cameraNode.camera = SCNCamera()
        cell?.objectView.scene?.rootNode.addChildNode(cameraNode)

        // Place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        
        // Create and add ambient to the scene
        let ambientLight = SCNNode(); ambientLight.light = SCNLight(); ambientLight.light?.type = .ambient
//        ambientLight.position = SCNVector3(x: 0, y: 0, z: 0)
        cell?.objectView.scene?.rootNode.addChildNode(ambientLight)
        
        // Create and add a light to the scene
        let omniLight = SCNNode(); omniLight.light = SCNLight(); omniLight.light!.type = .omni
        omniLight.position = SCNVector3(x: 10, y: 0, z: 10)
        cell?.objectView.scene?.rootNode.addChildNode(omniLight)

        cell?.objectView.scene?.rootNode.addChildNode(node)
        node.scale = SCNVector3(x: 90, y: 90, z: 90)
        node.eulerAngles.x = .pi/3
        node.eulerAngles.y = -.pi/4
        node.eulerAngles.z = -.pi/4
        
        // ** //
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Add a visual cue to indicate that the cell was selected.
//        self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        if let cell = self.tableView.cellForRow(at: indexPath) as? VirtualObjectTableViewCell {
            colorChoice = cell.colorChoice
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ViewController {
            destination.delegate = self
        }
    }
        
    func objectColor() -> UIColor {
        if let colorOfObject = colorChoice {
            return colorOfObject
        } else {
            return UIColor.yellow
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        // Invoked so we can prepare for a change in selection.
        // Remove previous selection, if any.
//        if let selectedIndex = self.tableView.indexPathForSelectedRow {
//            // Note: Programmatically deslecting does NOT invoke tableView(:didSelectRowAt:), so no risk of infinite loop.
//            self.tableView.deselectRow(at: selectedIndex, animated: false)
//            // Remove the visual selection indication.
//            self.tableView.cellForRow(at: selectedIndex)?.accessoryType = .none
//        }
        virtualObjectSelectedIndexPath = indexPath.row
        return indexPath
    }
}


