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
    
    let brain = Brain()
    
    // Name and Count of Objects - @TODO: Count should be increased as the use collects objects
    var virtualObjectsNames: [(name: String, count: Int)] {
        get {
            var result: [(name: String, count: Int)] = []
            for shape in brain.shapes {
                result.append((name: shape, count: 0))
            }
            return result
        }
    }
    
    // Name and UIColor object of Colors
    var virtualObjectsColors: [String: UIColor] {
        get {
            var result = [String: UIColor]()
            result["red"] = UIColor.red
            result["blue"] = UIColor.blue
            result["green"] = UIColor.green
            result["yellow"] = UIColor.yellow
            result["black"] = UIColor.black
            result["white"] = UIColor.white
            return result
        }
    }
    
    // Helper function to find name of the color when nodes are hit tested.
    func findColor(of node: SCNNode) -> String {
        if let key = virtualObjectsColors.aKey(forValue: node.geometry?.firstMaterial?.diffuse.contents as! UIColor) {
            return key
        } else {
            return "Not Found"
        }
    }
    
    // Get scenarios out of array of scenario of similar difficulty
    func getScenarios(expectedLevel: Int) -> [(shape: String, color: String, score: Int)] {
        return brain.getScenarios(expectedScore: expectedLevel)
    }
    
    //  Create nodes from Object name - e.g. "cube"
    func createNodes(from object: String, with color: UIColor) -> SCNNode {
        
        let wrapperNode = SCNNode()
        if let virtualScene = SCNScene(named: object.capitalized + ".scn", inDirectory: "Assets.scnassets/Shapes") {
            for child in virtualScene.rootNode.childNodes {
                wrapperNode.addChildNode(child)
            }
        }
        let material = wrapperNode.childNodes[0].childNodes[1].geometry?.firstMaterial!
        material?.diffuse.contents = color
        return wrapperNode
    }
    
    // Private method to generate random Int between two given numbers.
    private func randRange (lower: Int, upper: Int) -> Int {
        return Int(UInt32(lower) + arc4random_uniform(UInt32(upper) - UInt32(lower) + 1))
    }
}

// Extension to obtain key to a corresponding value in a Dictionary
extension Dictionary where Value: Equatable {
    func aKey(forValue val: Value) -> Key? {
        return first(where: { $1 == val })?.key
    }
}

