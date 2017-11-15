//
//  FocusSquare.swift
//  ARKitBasics
//
//  Created by Abhinav Prakash on 27/10/17.
//  Copyright © 2017 Apple. All rights reserved.


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
    
    // No instance variable?
    
    // MARK: Instance Method to create Square1
    func createFocusSquare() -> SCNNode {
        
        let wrapperNode = SCNNode()
        
        if let virtualObject = SCNScene(named: "OpenSquare.scn", inDirectory: "Assets.scnassets") {
            for child in virtualObject.rootNode.childNodes {
                wrapperNode.addChildNode(child)
            }
        }
        
        // Actual Size of the OpenSquare is  3*3*3 which is scaled down below
        wrapperNode.scale = SCNVector3(0.1, 0.1, 0.1)

        return wrapperNode
    }
}
