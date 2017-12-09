//
//  ViewController+ARSCNView.swift
//  ARKitBasics
//
//  Created by Abhinav Prakash on 09/11/17.
//  Copyright © 2017 Apple. All rights reserved.


import UIKit
import SceneKit
import ARKit


extension ViewController: ARSessionDelegate, ARSCNViewDelegate {
    
    /// - Tag: PlaceARContent
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        if let numberOfAnchorsInScene = sceneView.session.currentFrame?.anchors.count {
            if !inStateOfPlay {
//            if numberOfAnchorsInScene <= 4 {
                // Place content only for anchors found by plane detection.
                guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
                
                let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x),
                                     height: CGFloat(planeAnchor.extent.z))
                let planeNode = SCNNode(geometry: plane)
                planeNode.name = "anchorPlane"
                planeNode.simdPosition = float3(planeAnchor.center.x, 0, planeAnchor.center.z)
                
                DispatchQueue.global(qos: .userInitiated).async {
                    
                    switch numberOfAnchorsInScene {
                    // Says: "That's one. Keep moving around"
                    case 1: self.speech.sayWithInterruption(text: "That's one. Keep moving around")
                    // Says: "Makes it two"
                    case 2: self.speech.sayWithInterruption(text: "Makes it two")
                    // Says: "Three surfaces now"
                    case 3: self.speech.sayWithInterruption(text: "Three surfaces now")
                    // Says: "One more to go."
                    case 4:
                        self.speech.sayWithInterruption(text: "Hit Play anytime to get started")
                        DispatchQueue.main.async {
                            self.playButton.isHidden = false
                        }
                    default: break
                    }
                }
                
                /*
                 `SCNPlane` is vertically oriented in its local coordinate space, so
                 rotate the plane to match the horizontal orientation of `ARPlaneAnchor`.
                 */
                planeNode.eulerAngles.x = -.pi / 2
                
                // Make the plane visualization semitransparent to clearly show real-world placement.
                planeNode.opacity = 0.2
                
                /*
                 Add the plane visualization to the ARKit-managed node so that it tracks
                 changes in the plane anchor as plane estimation continues. Append the added
                 node to the collection to node - which is used in play mode to place other
                 objects.
                 */
                node.addChildNode(planeNode)
                nodesAddedInScene[node] = [planeAnchor.center, planeAnchor.extent]
                
            }
//            else {
//                DispatchQueue.main.async {
//                    self.playButton.isHidden = false
//                }
//            }
        }
    }
    
    // Note: sceneView.session.currentFrame?.anchors gives an array of all anchors added to the scene.
    
    /// - Tag: UpdateARContent
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // Update content only for plane anchors and nodes matching the setup created in `renderer(_:didAdd:for:)`.
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
        
        // Plane estimation may shift the center of a plane relative to its anchor's transform.
        planeNode.simdPosition = float3(planeAnchor.center.x, 0, planeAnchor.center.z)
        nodesAddedInScene[node] = [planeAnchor.center, planeAnchor.extent]
        
        /*
         Plane estimation may extend the size of the plane, or combine previously detected
         planes into a larger one. In the latter case, `ARSCNView` automatically deletes the
         corresponding node for one plane, then calls this method to update the size of
         the remaining plane.
         */
        plane.width = CGFloat(planeAnchor.extent.x)
        plane.height = CGFloat(planeAnchor.extent.z)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        nodesAddedInScene.removeValue(forKey: node)
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            let featurePointArray = self.sceneView.hitTest(self.screenCenter, types: .featurePoint)
            if let distanceFromCamera = featurePointArray.first?.distance {
                self.arrayFeaturePointDistance.append(distanceFromCamera)
                self.arrayFeaturePointDistance = Array(self.arrayFeaturePointDistance.suffix(10))
                let average = self.arrayFeaturePointDistance.reduce(CGFloat(0), { $0 + $1 }) / CGFloat(self.arrayFeaturePointDistance.count)
                self.sceneView.pointOfView?.childNodes[0].position.z = min(-0.6, Float(-average))
                self.sceneView.pointOfView?.childNodes[0].eulerAngles.x = (self.sceneView.session.currentFrame?.camera.eulerAngles.x)!
            }
        }
    }
    
    // Testing: @TODO: - Smoothening of object placement and change in focussquare orientation on camera movement
    
    // MARK: - ARSessionDelegate
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }
    
    
    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        updateSessionInfoLabel(for: session.currentFrame!, trackingState: camera.trackingState)
    }
    
    // MARK: - ARSessionObserver
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay.
        sessionInfoLabel.text = "Session was interrupted"
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required.
        sessionInfoLabel.text = "Session interruption ended"
        resetTracking()
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user.
        sessionInfoLabel.text = "Session failed: \(error.localizedDescription)"
        resetTracking()
    }
    
    // MARK: - Private methods
    
    private func updateSessionInfoLabel(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        // Update the UI to provide feedback on the state of the AR experience.
        let message: String
        
        switch trackingState {
        case .normal where frame.anchors.isEmpty:
            // No planes detected; provide instructions for this app's AR interactions.
            message = "Move the device around to detect horizontal surfaces."
            
        case .normal:
            // No feedback needed when tracking is normal and planes are visible.
            message = ""
            
        case .notAvailable:
            message = "Tracking unavailable."
            
        case .limited(.excessiveMotion):
            message = "Tracking limited - Move the device more slowly."
            
        case .limited(.insufficientFeatures):
            message = "Tracking limited - Point the device at an area with visible surface detail, or improve lighting conditions."
            
        case .limited(.initializing):
            message = "Initializing AR session."
            speech.say(text: "We will detect a few surfaces. Please move your device around")
        }
        
        sessionInfoLabel.text = message
        sessionInfoView.isHidden = message.isEmpty
    }
    
    func resetTracking() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        // To make sure almost everything re-runs when a user resets his/ her experience.
        // Game starts only when inStateOfPlayForGestureControl is false
        
        inStateOfPlay = false
        playButton.isHidden = true
        playButton.setBackgroundImage(imgPlay, for: .normal)
        audio.isHidden = true
        chosenScenarios.removeAll()
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
}
