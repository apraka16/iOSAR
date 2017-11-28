//
//  VirtualObjectTableViewCell.swift
//  ARKitBasics
//
//  Created by Abhinav Prakash on 14/11/17.
//  Copyright © 2017 Apple. All rights reserved.


import UIKit
import SceneKit

class VirtualObjectTableViewCell: UITableViewCell {
        
    @IBOutlet weak var objectTitle: UILabel!
    @IBOutlet weak var objectColorControl: UISegmentedControl!
    
    private var virtualObjects = VirtualObjects()
    private var colorOfObjects = ColorOfObjects()


    @IBOutlet weak var objectView: SCNView!
    @IBAction func updateColor(_ sender: Any) {
        if let material = objectView.scene?.rootNode.childNodes.last?.childNodes.first?.childNodes.last?.geometry?.firstMaterial {
            material.diffuse.contents = colorChoice
//            material.emission.contents = colorChoice
        }
    }
    
    private var colorChoices: [UIColor] {
        get {
            var result: [UIColor] = []
            result.append(colorOfObjects.UIColorFromRGB(rgbValue: colorOfObjects.blueColor))
            result.append(colorOfObjects.UIColorFromRGB(rgbValue: colorOfObjects.greenColor))
            result.append(colorOfObjects.UIColorFromRGB(rgbValue: colorOfObjects.redColor))
    
            return result
        }
    }
    
    var colorChoice: UIColor {
        return colorChoices[objectColorControl?.selectedSegmentIndex ?? 0]
    }
}

