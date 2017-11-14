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

struct VirtualObjects {
    
    // Stored Property for .scn objects
    
    var virtualObjects = [(scn:"Cube.scn", count: 0), (scn: "Sphere.scn", count: 0)]
    
    
    public var virtualObjectCountArray: [(name: String, count: Int)] {
        get {
            var resultArray: [(name: String, count: Int)] = []
            for object in virtualObjects {
                if virtualObjects.count != 0 {
                    let result = (name: virtualObjectsNames(from: object.scn), count: object.count)
                    resultArray.append(result)
                }
            }
            return resultArray
        }
    }
    
    
    private func virtualObjectsNames(from scnName: String) -> String {
        return scnName.replacingOccurrences(of: ".scn", with: "")
    }
    
    // Private method to create nodes from .scn objects
    func createNodes(from object: String) -> SCNNode {
    
        let wrapperNode = SCNNode()
        if let virtualScene = SCNScene(named: object + ".scn", inDirectory: "Assets.scnassets") {
            for child in virtualScene.rootNode.childNodes {
                wrapperNode.addChildNode(child)
            }
        }
        return wrapperNode
    }
    
}

