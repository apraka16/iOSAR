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
    
    /// Experimental - //
    
    @objc
    func insertObject(_ newObject: SCNNode) {
        // Database udpate - overridden in subclass
    }
    
    //    private func distanceFromCamera() {
    //        return sceneView.
    //    }
    
    
    private func action(on node: SCNNode, for key: String) {
        let actionJump = SCNAction.sequence([SCNAction.scale(to: 0.7, duration: 0.1), SCNAction.scale(to: 1, duration: 0.05)])
        
        switch key {
        case "vanish":
            DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                self?.sound.playSound(named: "swoosh")
                self?.speech.sayWithInterruptionAndDelay(text: (self?.speech.randomAccolade)!, delay: 0.1)
                self?.speech.say(text: "For next hit Play.")
                
                // Remove existing objects, restart the game.
                DispatchQueue.main.async {
                    node.name = "target"
                    self?.startPlay(playing: false)
                }
            }
            
            DispatchQueue.global(qos: .utility).async { [weak self] in
                self?.manageGameLevels(for: "vanish")
            }
            
            node.name = "target"
            
            // Removed the node from the 'display' located bottom right
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) { [weak self] in
                self?.removeNodeFromDisplay()
            }
            
        case "jump":
            DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                self?.sound.playSound(named: "jump")
                self?.speech.sayWithInterruptionAndDelay(text: (self?.speech.randomNegation)!, delay: 0.05)
                self?.speech.sayNegativeExplanation(
                    color: (self?.virtualObjectInstance.findColor(of: node.childNodes.last!))!,
                    shape: node.name!)
            }
            
            DispatchQueue.global(qos: .utility).async { [weak self] in
                self?.manageGameLevels(for: "jump")
            }
            
            node.parent?.runAction(actionJump)
            
        default: break
        }
    }
    
    // Perform level increment/ decrement and scene complexity increment/ decrement
    private func manageGameLevels(for key: String) {
        switch key {
        case "vanish":
            countOfConsecutiveLosses = 1
            if indexOfPoolProbabilities == virtualObjectInstance.arrayOfProbabilities.count {
                sceneComplexity = 0.8
            } else if countOfConsecutiveWins == 5 {
                indexOfPoolProbabilities += 1
                sceneComplexity = 0.2
                countOfConsecutiveWins = 1
            } else {
                countOfConsecutiveWins += 1
                if sceneComplexity < 1.0 {
                    sceneComplexity += 0.2
                }
            }
            
            // Debug
//            print("VANISH - Consecutive Wins: \(countOfConsecutiveWins)")
//            print("VANISH - Consecutive Losses: \(countOfConsecutiveLosses)")
//            print("VANISH - Index Pool Prob: \(indexOfPoolProbabilities)")
//            print("VANISH - Scene Complexity: \(sceneComplexity)")
            
            defaults.set(countOfConsecutiveWins, forKey: "countOfConsecutiveWins")
            defaults.set(countOfConsecutiveLosses, forKey: "countOfConsecutiveLosses")
            defaults.set(indexOfPoolProbabilities, forKey: "indexOfPoolProbabilities")
            defaults.set(sceneComplexity, forKey: "sceneComplexity")
            
        case "jump":
            countOfConsecutiveWins = 1
            if indexOfPoolProbabilities == 1 {
                sceneComplexity = 0.2
            } else if countOfConsecutiveLosses == 5 {
                indexOfPoolProbabilities -= 1
                sceneComplexity = 0.2
                countOfConsecutiveLosses = 1
            } else {
                countOfConsecutiveLosses += 1
                if sceneComplexity > 0.2 {
                    sceneComplexity -= 0.2
                }
            }
            
            // Debug
//            print("JUMP - Consecutive Wins: \(countOfConsecutiveWins)")
//            print("JUMP - Consecutive Losses: \(countOfConsecutiveLosses)")
//            print("JUMP - Index Pool Prob: \(indexOfPoolProbabilities)")
//            print("JUMP - Scene Complexity: \(sceneComplexity)")
            
            defaults.set(countOfConsecutiveWins, forKey: "countOfConsecutiveWins")
            defaults.set(countOfConsecutiveLosses, forKey: "countOfConsecutiveLosses")
            defaults.set(indexOfPoolProbabilities, forKey: "indexOfPoolProbabilities")
            defaults.set(sceneComplexity, forKey: "sceneComplexity")
            
        default:
            break
        }
    }
    
    // MARK: - Gesture Methods
    
    @objc
    func collectObject(_ gestureRecognize: UITapGestureRecognizer) {
        if !inStateOfPlay {
            return
        }
        let p = gestureRecognize.location(in: sceneView)
        let hitResults = sceneView.hitTest(p, options: [:])
        if hitResults.count > 0 && hitResults.first?.node.name != "anchorPlane" && hitResults.first?.node.name != "crosshair" {
            let result = hitResults.first!            
            if (result.node.parent?.name) != nil {
                let nodeToBeRemoved = result.node.parent!
                
                if let nodeWithAttributes = chosenScenarioForChallenge {
                    switch nodeToBeRemoved.name {
                    case nodeWithAttributes.shape? :
                        switch virtualObjectInstance.findColor(of: nodeToBeRemoved.childNodes.last!) {
                        case nodeWithAttributes.color :
                            action(on: nodeToBeRemoved, for: "vanish")
                            
                        default:
                            action(on: nodeToBeRemoved, for: "jump")
                            // This actually is a non-hygienic way - think of alternative
                            // Queuing is not proper - at times one statement is spoken first
                            // and others - other one. @TODO
                            DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                                self?.speech.sayNegativeExplanation(
                                    color: (self?.virtualObjectInstance.findColor(of: nodeToBeRemoved.childNodes.last!))!,
                                    shape: nodeToBeRemoved.name!)
                            }
                        }
                        
                    default:
                        action(on: nodeToBeRemoved, for: "jump")
                        // This actually is a non-hygienic way - think of alternative
                        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                            self?.speech.sayNegativeExplanation(
                                color: (self?.virtualObjectInstance.findColor(of: nodeToBeRemoved.childNodes.last!))!,
                                shape: nodeToBeRemoved.name!)
                        }
                    }
                }
            }
        }
    }
    
}






