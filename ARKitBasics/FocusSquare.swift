//
//  FocusSquare.swift
//  ARKitBasics
//
//  Created by Abhinav Prakash on 27/10/17.
//  Copyright © 2017 Apple. All rights reserved.
//

/* The intention is to create a square which will be used for creating targets
 for placing objects in AR view.
 /* Square1: The square should appear as below when initialized:
      _      _
     |        |

     |_      _|
 
 Square2: The square should appear as below when horizontal plane is detected (target locked):
      ________
     |        |
     |        |
     |________|
 */
*/

import Foundation
import SceneKit

class FocusSquare {
    
    // MARK: Instance variables
    private let color: UIColor = UIColor.red
    private let fillColor: UIColor = UIColor.green
    
    // MARK: Instance Method to create Square1
    func createFocusSquare(atX xCoord: CGFloat, atY yCoord: CGFloat) -> SCNNode {
        let path = UIBezierPath(rect: CGRect(x: xCoord, y: yCoord, width: 0.2, height: 0.2))
        path.lineWidth = 0.01
        color.setStroke()
        path.stroke()
        fillColor.setFill()
        path.fill()
        
        let shape = SCNShape(path: path, extrusionDepth: 0)
        
        return SCNNode(geometry: shape)
    }
}
