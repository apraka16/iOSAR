//
//  ViewController+Animation.swift
//  ARKitBasics
//
//  Created by Abhinav Prakash on 09/12/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

extension ViewController: CAAnimationDelegate {
    
    // CAAnimation object - apply to nodes for animating transition, rotation and fading
    func riseUpSpinAndFadeAnimation(on shape: SCNNode) {
        let riseUpAnimation = CABasicAnimation(keyPath: "position")
        riseUpAnimation.fromValue = SCNVector3(shape.position.x, shape.position.y, shape.position.z)
        riseUpAnimation.toValue = SCNVector3(shape.position.x, shape.position.y + 1.0, shape.position.z)
        
        let spinAnimation = CABasicAnimation(keyPath: "eulerAngles.y")
        spinAnimation.toValue = shape.eulerAngles.y + 180.0
        
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.toValue = 0.0
        
        let riseUpSpinAndFadeAnimation = CAAnimationGroup()
        riseUpSpinAndFadeAnimation.animations = [riseUpAnimation, fadeAnimation, spinAnimation]
        riseUpSpinAndFadeAnimation.duration = 1.0
        riseUpSpinAndFadeAnimation.fillMode = kCAFillModeForwards
        riseUpSpinAndFadeAnimation.isRemovedOnCompletion = false
        
        shape.addAnimation(riseUpSpinAndFadeAnimation, forKey: "riseUpSpinAndFade")
    }
    
    // CAAnimation object - apply to nodes for fading
    func fadeAnimation(on shape: SCNNode) {
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.toValue = 0.0
        fadeAnimation.duration = 0.3
        fadeAnimation.fillMode = kCAFillModeForwards
        fadeAnimation.isRemovedOnCompletion = false
        shape.addAnimation(fadeAnimation, forKey: "fade")
    }
    
    
}

