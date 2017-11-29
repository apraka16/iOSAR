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
//                self.sound.playSound(named: "swoosh") // Probably not needed since textToSpeech included
                self.speech.say(text: self.speech.randomAccolade)
            }
            
            // Add code for updating count
            // @TODO - 
            
            node.runAction(actionVanish)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) { [weak self] in
                node.parent?.removeFromParentNode()
                self?.segueButton.setBackgroundImage(UIImage(named: "cube-blue"), for: .normal)
            }
        case "jump":
            DispatchQueue.global(qos: .userInteractive).async {
//                self.sound.playSound(named: "jump") // Probably not needed since textToSpeech included
                self.speech.say(text: self.speech.randomNegation)
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
    func collectObject(_ gestureRecognize: UITapGestureRecognizer) {
        if !inStateOfPlayForGestureControl {
            return
        }
        let p = gestureRecognize.location(in: sceneView)
        let hitResults = sceneView.hitTest(p, options: [:])
        if hitResults.count > 0 && hitResults.first?.node.name != "anchorPlane" {
            let result = hitResults.first!
            
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
                        action(on: nodeToBeRemoved, for: "jump")
                    }
                default:
                    action(on: nodeToBeRemoved, for: "jump")
                }
            }

        }
    }
    
    
    // Pop-up options for color change of the object on longpress
    @objc
    func changeColorOfObject(_ gestureRecognize: UILongPressGestureRecognizer) {
        colorPicker.isHidden = false
        
        let p = gestureRecognize.location(in: sceneView)
        let hitResults = sceneView.hitTest(p, options: [:])
        if hitResults.count > 0 && hitResults.first?.node.name != "anchorPlane" {
            let result = hitResults[0]
            material = result.node.geometry!.firstMaterial!
        }
        else {
            colorPicker.isHidden = true
        }
    }
    
}






