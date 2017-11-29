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
    
    private var colorOfObjects = ColorOfObjects()
    
    // Colors
    private let redColor: UInt = 0xF03434
    private let greenColor: UInt = 0x019875
    private let blueColor: UInt = 0x013243
    
    var virtualObjectsNames = [(name: "cube", scn: "Cube.scn", count: 0),
                               (name: "sphere", scn: "Sphere.scn", count: 0)]
    
    var virtualObjectsColors: [String: UIColor] {
        get {
            var result = [String: UIColor]()
            result["red"] = colorOfObjects.UIColorFromRGB(rgbValue: redColor)
            result["blue"] = colorOfObjects.UIColorFromRGB(rgbValue: blueColor)
            result["green"] = colorOfObjects.UIColorFromRGB(rgbValue: greenColor)
            return result
        }
    }
    
    var virtualObjectCount: [(name: String, count: Int)] {
        get {
            var result: [(name: String, count: Int)] = []
            for object in virtualObjectsNames {
                if virtualObjectsNames.count != 0 {
                    result.append((name: object.name, count: object.count))
                }
            }
            return result
        }
    }

    
    // Helper function to find name of the color when nodes are hit test.
    func findColor(of node: SCNNode) -> String {
        var color = ""
        switch node.geometry?.firstMaterial?.diffuse.contents as! UIColor {
        case colorOfObjects.UIColorFromRGB(rgbValue: colorOfObjects.blueColor):
            color = "blue"
        case colorOfObjects.UIColorFromRGB(rgbValue: colorOfObjects.greenColor):
            color = "green"
        case colorOfObjects.UIColorFromRGB(rgbValue: colorOfObjects.redColor):
            color = "red"
        default:
            break
        }
        return color
    }
    
    // To generate problems for the child randomly
    var randomCombination: (name: String, color: String) {
        get {
            let names = ["cube", "sphere"]
            let colors = ["red", "blue", "green"]
            return (name: names[randRange(lower: 0, upper: 1)], color: colors[randRange(lower: 0, upper: 2)])
        }
    }
    
    private func virtualObjectsNames(from scnName: String) -> String {
        return scnName.replacingOccurrences(of: ".scn", with: "")
    }
    
    //  Create nodes from Object name - e.g. "cube"
    func createNodes(from object: String, with color: UIColor) -> SCNNode {
    
        let wrapperNode = SCNNode()
        if let virtualScene = SCNScene(named: object.capitalized + ".scn", inDirectory: "Assets.scnassets") {
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

