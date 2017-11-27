//
//  VirtualObjects.swift
//  ARKitBasics
//
//  Created by Abhinav Prakash on 25/10/17.
//  Copyright © 2017 Apple. All rights reserved.


/** Class created to change .scn objects to node and add those into an array **/

import Foundation
import SceneKit

class VirtualObjects {
    
    // Stored Property for .scn objects
    var virtualObjects = [(scn:"Cube.scn", count: 0),
                          (scn: "Sphere.scn", count: 0)]
        
    let colorOfObject = ColorOfObjects()
    
    public var virtualObjectCountArray: [(name: String, count: Int)] {
        get {
//            insertVirtualObjects()
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
    
    //  Create nodes from Object name - e.g. "Cube"
    // @TODO: Think of better way to create nodes, than via using string concatenation
    func createNodes(from object: String, with color: UIColor) -> SCNNode {
    
        let wrapperNode = SCNNode()
        if let virtualScene = SCNScene(named: object + ".scn", inDirectory: "Assets.scnassets") {
            for child in virtualScene.rootNode.childNodes {
                wrapperNode.addChildNode(child)
            }
        }
        let material = wrapperNode.childNodes[0].childNodes[1].geometry?.firstMaterial!
        material?.emission.contents = color
        return wrapperNode
    }
    
    // Random Node Generator
    
    private let objectNames = ["Cube", "Sphere"]
    private var objectColors: [UIColor] {
        get {
            return [
                colorOfObject.UIColorFromRGB(rgbValue: colorOfObject.blueColor),
                colorOfObject.UIColorFromRGB(rgbValue: colorOfObject.greenColor),
                colorOfObject.UIColorFromRGB(rgbValue: colorOfObject.redColor)
            ]
        }
    }
    
    private func randRange (lower: Int, upper: Int) -> Int {
        return Int(UInt32(lower) + arc4random_uniform(UInt32(upper) - UInt32(lower) + 1))
    }
    
    func createRandomNodes() -> SCNNode {
        let randomObjectName = objectNames[randRange(lower: 0, upper: 1)]
        let randomObjectColor = objectColors[randRange(lower: 0, upper: 2)]
        return createNodes(from: randomObjectName, with: randomObjectColor)
    }
}

