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


    @IBOutlet weak var objectView: VirtualObjectDisplay!
    @IBAction func updateColor(_ sender: Any) {
        if let material = objectView.scene?.rootNode.childNodes[2].childNodes[0].childNodes[1].geometry?.firstMaterial {
            material.emission.contents = colorChoice
        }
    }
    
    private var colorChoices: [UIColor] {
        get {
            var result: [UIColor] = []
            result.append(UIColorFromRGB(rgbValue: 0x013243))
            result.append(UIColorFromRGB(rgbValue: 0x019875))
            result.append(UIColorFromRGB(rgbValue: 0xF03434))
            
            return result
        }
    }
    
    var colorChoice: UIColor {
        return colorChoices[objectColorControl?.selectedSegmentIndex ?? 0]
    }
}

// Extension to change color from Hex to UIColor
extension UITableViewCell {
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
