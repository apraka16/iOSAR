//
//  ViewController+Gestures.swift
//  ARKitBasics
//
//  Created by Abhinav Prakash on 16/11/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit
import ARKit

extension ViewController: UIGestureRecognizerDelegate {
    
    // MARK: - Gesture Methods
    
    @objc
    func rotateObject(_ gestureRecognize: UISwipeGestureRecognizer) {
        let p = gestureRecognize.location(in: sceneView)
        let hitResults = sceneView.hitTest(p, options: [:])
        if hitResults.count > 0 && hitResults.first?.node.name != "plane" {
            let result = hitResults.first!
            switch gestureRecognize.direction {
            case .left:
                sound.playSound(named: "zip")
                result.node.runAction(SCNAction.rotateBy(x: 0, y: 0, z: -1, duration: 0.25))
            case .right:
                sound.playSound(named: "zip")
                result.node.runAction(SCNAction.rotateBy(x: 0, y: 0, z: 1, duration: 0.25))
            case .down:
                sound.playSound(named: "swoosh")
                
                // Down to remove object and show as collected in Segue button - bottom right
                segueButton.isHidden = false
                
                if (result.node.parent?.name) != nil {
                    if result.node.parent?.parent?.parent?.childNodes[1].name == "plane" {
                        result.node.parent?.parent?.parent?.childNodes[1].isHidden = false
                    }
                    
                    let nodeToBeRemoved = (result.node.parent?.name)!
                    switch nodeToBeRemoved {
                    case "cube" :
                        segueButton.setBackgroundImage(UIImage(named: "cube"), for: .normal)
                        virtualObjectInstance.virtualObjects[0].count += 1
                        result.node.parent?.removeFromParentNode()
                    case "sphere" :
                        segueButton.setBackgroundImage(UIImage(named: "sphere"), for: .normal)
                        virtualObjectInstance.virtualObjects[1].count += 1
                        result.node.parent?.removeFromParentNode()
                    default:
                        break
                    }
                }
//                tappedNode?.isHidden = false
            default:
                break
            }
        }
    }
    
    // Rotate object using two finger rotation - more intuitive than swipe rotation
    @objc
    func rotateObjects(_ gestureRecognize: UIRotationGestureRecognizer) {
        let p = gestureRecognize.location(in: sceneView)
        let hitResults = sceneView.hitTest(p, options: [:])
        if hitResults.count > 0 && hitResults.first?.node.name != "plane" {
            let result = hitResults.first!
            result.node.eulerAngles.z -= Float(gestureRecognize.rotation)
            gestureRecognize.rotation = 0.0
        }
    }
    
    // Scale the Object on pinch
    @objc
    func changeScale(_ gestureRecognize: UIPinchGestureRecognizer) {
        let p = gestureRecognize.location(in: sceneView)
        let hitResults = sceneView.hitTest(p, options: [:])
        if hitResults.count > 0 && hitResults.first?.node.name != "plane" {
            let result = hitResults[0]
            switch gestureRecognize.state {
            case .changed, .ended:
//                result.node.scale = SCNVector3(gestureRecognize.scale, gestureRecognize.scale, gestureRecognize.scale)
                result.node.scale.x *= Float(gestureRecognize.scale)
                result.node.scale.y *= Float(gestureRecognize.scale)
                result.node.scale.z *= Float(gestureRecognize.scale)
                gestureRecognize.scale = 1
            default:
                break
            }
        }
    }
    
    // Pop-up options for color change of the object on longpress
    @objc
    func changeColorOfObject(_ gestureRecognize: UILongPressGestureRecognizer) {
        colorPicker.isHidden = false
        
        let p = gestureRecognize.location(in: sceneView)
        let hitResults = sceneView.hitTest(p, options: [:])
        if hitResults.count > 0 && hitResults.first?.node.name != "plane" {
            let result = hitResults[0]
            material = result.node.geometry!.firstMaterial!
        }
        else {
            colorPicker.isHidden = true
        }
    }
    
    // Pan Gesture - to allow object to pan around
    // @TODO:- Do Not allow object to go beyond anchor's extent
    @objc
    func translateObject(_ gestureRecognize: UIPanGestureRecognizer) {
        
        let p = gestureRecognize.location(in: sceneView)
        let hitResults = sceneView.hitTest(p, options: [:])
        if hitResults.count > 0 && hitResults.first?.node.name != "plane" {
            let result = hitResults[0]
            
            let anchor = sceneView.anchor(for: result.node)
            guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
            let anchorWidth = planeAnchor.extent.x
            let anchorHeight = planeAnchor.extent.z
            
            let translation = gestureRecognize.translation(in: sceneView)
            
            if gestureRecognize.state != .cancelled {
                result.node.position.x += Float(translation.x) * anchorWidth / Float(sceneView.bounds.height)
                result.node.position.y -= Float(translation.y) * anchorHeight / Float(sceneView.bounds.width)
                gestureRecognize.setTranslation(CGPoint.zero, in: sceneView)

            }
        }
        
    }
}






