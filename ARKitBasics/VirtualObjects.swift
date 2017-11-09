//
//  VirtualObjects.swift
//  ARKitBasics
//
//  Created by Abhinav Prakash on 25/10/17.
//  Copyright © 2017 Apple. All rights reserved.
//

/** Class created to change .scn objects to node and add those into an array **/

import Foundation
import SceneKit

class VirtualObjects {
    
    // Stored Property for .scn objects
    var virtualObjects = ["Cube.scn", "Sphere.scn"]
    
    // Computed Property - Public to get all nodes
    var virtualObjectNodes: [SCNNode] {
        get {
            return createNodes(from: virtualObjects)
        }
    }
    
    // Private method to create nodes from .scn objects
    private func createNodes(from objects: [String]) -> [SCNNode] {
        
        var objectNodes = [SCNNode]()
        
        for object in virtualObjects {
            let wrapperNode = SCNNode()
            if let virtualScene = SCNScene(named: object, inDirectory: "Assets.scnassets") {
                for child in virtualScene.rootNode.childNodes {
                    wrapperNode.addChildNode(child)
                }
            }
            objectNodes.append(wrapperNode)
        }
        return objectNodes
        
    }
    
}

