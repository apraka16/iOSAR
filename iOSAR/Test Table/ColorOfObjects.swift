//
//  Color.swift
//  ARKitBasics
//
//  Created by Abhinav Prakash on 15/11/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation
import UIKit

class ColorOfObjects {
    
    public let redColor: UInt = 0xF03434
    public let greenColor: UInt = 0x019875
    public let blueColor: UInt = 0x013243
    
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}


