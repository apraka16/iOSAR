//
//  VirtualObjectsViewController.swift
//  ARKitBasics
//
//  Created by Abhinav Prakash on 25/10/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit
import SceneKit

class VirtualObjectsViewController: UIViewController {
    
    // Property to store names of all SceneKit .scn models
    private var virtualObjects = ["Cube.scn", "Floor.scn"]
    
    // Public computed property: returns nodes created from SceneKit elements
    var virtualObjectNodes: [SCNNode] {
        get {
            return createNodes(from: virtualObjects)
        }
    }
    
    // Private method to create an array of nodes from SceneKit objects
    private func createNodes(from nodeNames: [String]) -> [SCNNode] {
        
        var virtualObjectNodes = [SCNNode]()
        
        for object in virtualObjects {
            let wrapperNode = SCNNode()
            if let virtualScene = SCNScene(named: object, inDirectory: "Assets.scnassets") {
                for child in virtualScene.rootNode.childNodes {
                    wrapperNode.addChildNode(child)
                }
            }
            
            virtualObjectNodes.append(wrapperNode)
        }
        
        return virtualObjectNodes
    }
}
