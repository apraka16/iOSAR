//
//  Crosshairs.swift
//  ARKitBasics
//
//  Created by Abhinav Prakash on 23/11/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation
import SceneKit

/* Implementation of Focus Square (Crosshairs) as a separate class
 @TODO:-
 1. Think of Animation and its implementation
 2. Differeing square type depending on detected planes/ NOT-detected planes
 */

class Crosshairs: SCNNode {

    /* Crosshairs is made up of 8 segments - 4 vertically and 4 horizontally situated, as in figure below
     
     /* Crosshairs' style
         s1 s2
         _   _
     s3 |     | s4
     
     s5 |_   _| s6
     s7 s8
     */
     
    */
    
    private var nameOfNode = "crosshair"
    
    // Node to attach all segments nodes to
    private let crosshairNode = SCNNode()
    
    // Height of a segment
    private let thick: CGFloat = 0.05
    
    // Width of a segment
    private let thin: CGFloat = 0.002
    
    /* Since a thin line segment node starts at a corner, two kinds of offsets are required
     to arrange all 8 segments into an open square */
    private let smallOffset: Float = 0.075
    private let largeOffset: Float = 0.05    
    
    // Color of the border of Crosshairs
    private let borderColor = UIColor.yellow
    
    
    // Color of filled-in plane of Crosshairs
    private let fillColor = UIColor.yellow
    
    override init() {
        super.init()
        
        let s1 = SCNNode(geometry: SCNPlane(width: thick, height: thin))
        let s2 = SCNNode(geometry: SCNPlane(width: thick, height: thin))
        let s7 = SCNNode(geometry: SCNPlane(width: thick, height: thin))
        let s8 = SCNNode(geometry: SCNPlane(width: thick, height: thin))
        
        let s3 = SCNNode(geometry: SCNPlane(width: thin, height: thick))
        let s4 = SCNNode(geometry: SCNPlane(width: thin, height: thick))
        let s5 = SCNNode(geometry: SCNPlane(width: thin, height: thick))
        let s6 = SCNNode(geometry: SCNPlane(width: thin, height: thick))
            
        s1.geometry?.firstMaterial?.diffuse.contents = borderColor
        s2.geometry?.firstMaterial?.diffuse.contents = borderColor
        s3.geometry?.firstMaterial?.diffuse.contents = borderColor
        s4.geometry?.firstMaterial?.diffuse.contents = borderColor
        s5.geometry?.firstMaterial?.diffuse.contents = borderColor
        s6.geometry?.firstMaterial?.diffuse.contents = borderColor
        s7.geometry?.firstMaterial?.diffuse.contents = borderColor
        s8.geometry?.firstMaterial?.diffuse.contents = borderColor
        
        s1.simdPosition = float3(-largeOffset, smallOffset, 0.0)
        s2.simdPosition = float3(largeOffset, smallOffset, 0.0)
        s7.simdPosition = float3(-largeOffset, -smallOffset, 0.0)
        s8.simdPosition = float3(largeOffset, -smallOffset, 0.0)
        
        s3.simdPosition = float3(-smallOffset, largeOffset, 0.0)
        s4.simdPosition = float3(smallOffset, largeOffset, 0.0)
        s5.simdPosition = float3(-smallOffset, -largeOffset, 0.0)
        s6.simdPosition = float3(smallOffset, -largeOffset, 0.0)
        
        crosshairNode.name = nameOfNode
        
        crosshairNode.addChildNode(s1)
        crosshairNode.addChildNode(s2)
        crosshairNode.addChildNode(s7)
        crosshairNode.addChildNode(s8)
        
        crosshairNode.addChildNode(s3)
        crosshairNode.addChildNode(s4)
        crosshairNode.addChildNode(s5)
        crosshairNode.addChildNode(s6)

        addChildNode(crosshairNode)
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }
    
    func displayAsBillboard() {
        position.z = -0.5
    }
    
    func displayAsClosed() {
        
        /* Crosshairs' style
              c1
             _____
            |     |
         c2 |     | c3
            |_____|
              c4
         */
        
        let c1 = SCNNode(geometry: SCNPlane(width: thick, height: thin))
        let c4 = SCNNode(geometry: SCNPlane(width: thick, height: thin))
        let c2 = SCNNode(geometry: SCNPlane(width: thin, height: thick))
        let c3 = SCNNode(geometry: SCNPlane(width: thin, height: thick))
        
        c1.geometry?.firstMaterial?.diffuse.contents = borderColor
        c4.geometry?.firstMaterial?.diffuse.contents = borderColor
        c2.geometry?.firstMaterial?.diffuse.contents = borderColor
        c3.geometry?.firstMaterial?.diffuse.contents = borderColor
        
        c1.simdPosition = float3(0.0, smallOffset, 0.0)
        c4.simdPosition = float3(0.0, -smallOffset, 0.0)
        c2.simdPosition = float3(-smallOffset, 0.0, 0.0)
        c3.simdPosition = float3(smallOffset, 0.0, 0.0)
        
        
        crosshairNode.addChildNode(c1)
        crosshairNode.addChildNode(c4)
        crosshairNode.addChildNode(c2)
        crosshairNode.addChildNode(c3)
        

    }
    
    func displayAsFilled() {
        let c1 = SCNNode(geometry: SCNPlane(width: thick, height: thin))
        let c4 = SCNNode(geometry: SCNPlane(width: thick, height: thin))
        let c2 = SCNNode(geometry: SCNPlane(width: thin, height: thick))
        let c3 = SCNNode(geometry: SCNPlane(width: thin, height: thick))
        
        c1.geometry?.firstMaterial?.diffuse.contents = borderColor
        c4.geometry?.firstMaterial?.diffuse.contents = borderColor
        c2.geometry?.firstMaterial?.diffuse.contents = borderColor
        c3.geometry?.firstMaterial?.diffuse.contents = borderColor
        
        c1.simdPosition = float3(0.0, smallOffset, 0.0)
        c4.simdPosition = float3(0.0, -smallOffset, 0.0)
        c2.simdPosition = float3(-smallOffset, 0.0, 0.0)
        c3.simdPosition = float3(smallOffset, 0.0, 0.0)
        
        let p1 = SCNNode(geometry: SCNPlane(width: 0.15, height: 0.15))
        p1.geometry?.firstMaterial?.diffuse.contents = fillColor
        p1.opacity = 0.5
        
        crosshairNode.addChildNode(c1)
        crosshairNode.addChildNode(c4)
        crosshairNode.addChildNode(c2)
        crosshairNode.addChildNode(c3)
        
        crosshairNode.addChildNode(p1)
//        name = "closedCrosshair"
    }
    

}
