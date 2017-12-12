//
//  Crosshairs.swift
//  ARKitBasics
//
//  Created by Abhinav Prakash on 23/11/17.
//  Copyright © 2017 Apple. All rights reserved.

// TAG: Against DRY - look for changing it later

import Foundation
import SceneKit


class AnchorPlane: SCNNode {
    
    private let nameOfNode = "anchorNode"
    
    // Node to attach all segments nodes to
    private let anchorNode = SCNNode()
    
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
        
        anchorNode.name = nameOfNode
        
        anchorNode.addChildNode(s1)
        anchorNode.addChildNode(s2)
        anchorNode.addChildNode(s7)
        anchorNode.addChildNode(s8)
        
        anchorNode.addChildNode(s3)
        anchorNode.addChildNode(s4)
        anchorNode.addChildNode(s5)
        anchorNode.addChildNode(s6)
        
        addChildNode(anchorNode)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) has not been implemented")
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
        
        anchorNode.addChildNode(c1)
        anchorNode.addChildNode(c4)
        anchorNode.addChildNode(c2)
        anchorNode.addChildNode(c3)
        
        anchorNode.addChildNode(p1)
    }
    
    
}
