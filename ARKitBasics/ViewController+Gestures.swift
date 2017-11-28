//
//  ViewController+Gestures.swift
//  ARKitBasics
//
//  Created by Abhinav Prakash on 16/11/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit
import ARKit
import CoreData

extension ViewController: UIGestureRecognizerDelegate {
    
    /// Experimental -
    @objc
    func insertObject(_ newObject: SCNNode) {
        // Database udpate - overridden in subclass
    }
    
    private func action(on node: SCNNode, for key: String) {
        let actionJump = SCNAction.sequence([SCNAction.scale(to: 0.7, duration: 0.1), SCNAction.scale(to: 1, duration: 0.05)])
        let actionVanish = SCNAction.scale(to: 0.5, duration: 0.1)
        switch key {
        case "vanish":
            DispatchQueue.global(qos: .userInteractive).async {
                self.sound.playSound(named: "swoosh")
            }
            
            // Add code for updating count
            //
            
            node.runAction(actionVanish)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) { [weak self] in
                node.parent?.removeFromParentNode()
                self?.segueButton.setBackgroundImage(UIImage(named: "cube-blue"), for: .normal)
            }
        case "jump":
            DispatchQueue.global(qos: .userInteractive).async {
                self.sound.playSound(named: "jump")
            }
            node.parent?.runAction(actionJump)
        default: break
        }
    }
    
    private func randRange (lower: Int, upper: Int) -> Int {
        return Int(UInt32(lower) + arc4random_uniform(UInt32(upper) - UInt32(lower) + 1))
    }

    // MARK: - Gesture Methods
    
    @objc
    func rotateObject(_ gestureRecognize: UISwipeGestureRecognizer) {
        if !inStateOfPlayForGestureControl {
            return
        }
        let p = gestureRecognize.location(in: sceneView)
        let hitResults = sceneView.hitTest(p, options: [:])
        if hitResults.count > 0 && hitResults.first?.node.name != "anchorPlane" {
            let result = hitResults.first!
            switch gestureRecognize.direction {
            case .down:
                // Down to remove object and show as collected in Segue button - bottom right
                segueButton.isHidden = false
                
                if (result.node.parent?.name) != nil {
                    if let anchorNode = result.node.parent?.parent?.parent?.childNode(withName: "anchorNode", recursively: true) {
                        anchorNode.isHidden = false
                    }
                    
                    let nodeToBeRemoved = result.node.parent!
                    let nodeWithAttributes = randomCombination
                    
                    switch nodeToBeRemoved.name {
                    case nodeWithAttributes.name? :
                        switch virtualObjectInstance.findColor(of: nodeToBeRemoved.childNodes.last!) {
                        case nodeWithAttributes.color:
                            action(on: nodeToBeRemoved, for: "vanish")
                        default:
                            unhideGuides()
                            Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(hideGuides), userInfo: nil, repeats: false)
                            action(on: nodeToBeRemoved, for: "jump")
                        }
                    default:
                        unhideGuides()
                        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(hideGuides), userInfo: nil, repeats: false)
                        action(on: nodeToBeRemoved, for: "jump")
                    }
// ****
//                    switch nodeToBeRemoved {
//                    case "cube" :
//                        // Dipatching sounds to global queue (non-main) for no impact on UI
//                        DispatchQueue.global(qos: .userInteractive).async {
//                            self.sound.playSound(named: "swoosh")
//                        }
//                        segueButton.setBackgroundImage(UIImage(named: "cube"), for: .normal)
//
//                        /// Experimental function - testing database
//                        insertObject(result.node.parent!)
//
//                        virtualObjectInstance.virtualObjects[0].count += 1
//                        result.node.parent?.removeFromParentNode()
//                    case "sphere" :
//                        // Dipatching sounds to global queue (non-main) for no impact on UI
//                        DispatchQueue.global(qos: .userInteractive).async {
//                            self.sound.playSound(named: "swoosh")
//                        }
//                        segueButton.setBackgroundImage(UIImage(named: "sphere"), for: .normal)
//
//                        /// Experimental function - testing database
//                        insertObject(result.node.parent!)
//
//                        virtualObjectInstance.virtualObjects[1].count += 1
//
//                        result.node.parent?.removeFromParentNode()
//                    default:
//                        break
//                    }
// *******
                    
                }
//                tappedNode?.isHidden = false
            default:
                break
            }
        }
    }
    
    @objc
    func unhideGuides() {
        startPlayGuideImage.isHidden = false
        startPlayGuideLabel.isHidden = false
    }
    
    @objc
    func hideGuides() {
        startPlayGuideImage.isHidden = true
        startPlayGuideLabel.isHidden = true
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
    // @TODO:- Do Not allow object to go beyond anchor's extent - TOO JITTERY
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






