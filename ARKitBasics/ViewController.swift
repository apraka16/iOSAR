/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Main view controller for the AR experience.
*/

import UIKit
import SceneKit
import ARKit

protocol ColorObjectToVCDelegate {
    func objectColor() -> UIColor
}

class ViewController: UIViewController, VCFinalDelegate, UIPopoverPresentationControllerDelegate {
    
    // MARK: - Debug Purposes
    var delegate: ColorObjectToVCDelegate?
    private var scale: CGFloat = 1.0
    private var objectOnPathToBeAdded: Int?
    private var virtualObjectInstance = VirtualObjects()
    private var tappedNode: SCNNode?
    private var virtualObjectColor: UIColor?
    
    /* Segue Button at bottom right corner opens tableView (Container...) to keep score of
     swiped down objects from main view */
    // Outlet for changing background image of button depending on the object which is swiped down
    @IBOutlet weak var segueButton: UIButton!
    
    // Reset button - top right corner reset AR
    @IBAction func reset(_ sender: UIButton) {
        sender.showsTouchWhenHighlighted = true
        resetTracking()
    }
    
	// MARK: - IBOutlets
    // User tap on floor node to add 3D object
    @IBAction func userTap(_ sender: UITapGestureRecognizer) {
                
        if objectOnPathToBeAdded != nil {
            let objectToBeAdded = virtualObjectInstance.createNodes(from: virtualObjectInstance.virtualObjectCountArray[objectOnPathToBeAdded!].name, with: delegate?.objectColor() ?? UIColor.yellow)
            
            let touchLocation = sender.location(in: view)
            let hits = sceneView.hitTest(touchLocation, options: nil)
            if hits.first?.node != nil {
                tappedNode = hits.first?.node
                objectToBeAdded.position.z = (tappedNode?.position.z)! + 0.05
                tappedNode?.parent?.addChildNode(objectToBeAdded)
                tappedNode?.isHidden = true
            }
        }
    }
    
    // Segue button to segue to ContainerTableView
    @IBAction func btnPerformSeguePressed(_ sender: UIButton) {
        performSegue(withIdentifier: "ARSCNToTabView", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destinationViewController = segue.destination
        if let navigationController = destinationViewController as? UINavigationController {
            destinationViewController = navigationController.visibleViewController ?? destinationViewController
        }
        if let TableViewController = destinationViewController as? ContainerTableViewController {
            TableViewController.delegate = self
            if let popoverPresentationController = segue.destination.popoverPresentationController {
                popoverPresentationController.delegate = self
            }
        } else if destinationViewController is VirtualObjectTableViewController {
            if let popoverPresentationController = segue.destination.popoverPresentationController {
                popoverPresentationController.sourceView = sender as! UIButton
                popoverPresentationController.sourceRect = (sender as! UIButton).bounds
                popoverPresentationController.delegate = self
            }
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        if traitCollection.verticalSizeClass == .compact {
            return .none
        } else {
            return .none
        }
    }
    
    func passVirtualObject() -> [(name: String, count: Int)] {
        return virtualObjectInstance.virtualObjectCountArray
    }
    
    @IBOutlet weak var sessionInfoView: UIView!
	@IBOutlet weak var sessionInfoLabel: UILabel!
    @IBOutlet weak var sceneView: ARSCNView! {
        didSet {
            let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(highlightObject(_:)))
            swipeDownGesture.direction = .down
            sceneView.addGestureRecognizer(swipeDownGesture)
            
            let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(rotateObjectUp(_:)))
            swipeUpGesture.direction = .up
            sceneView.addGestureRecognizer(swipeUpGesture)
            
            let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(rotateObjectToLeft(_:)))
            swipeLeftGesture.direction = .left
            sceneView.addGestureRecognizer(swipeLeftGesture)
            
            let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(rotateObjectToRight(_:)))
            swipeRightGesture.direction = .right
            sceneView.addGestureRecognizer(swipeRightGesture)
            
            let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(changeScale(_:)))
            sceneView.addGestureRecognizer(pinchGesture)
        }
    }
    
    @IBAction func chooseVirtualObject(from segue: UIStoryboardSegue) {
        if let virtualObjectChosen = segue.source as? VirtualObjectTableViewController {
            if let path = virtualObjectChosen.virtualObjectSelectedIndexPath {
                objectOnPathToBeAdded = path
            }
        }
    }
    
    // MARK: - View Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        segueButton.isHidden = true
    }
	
    /// - Tag: StartARSession
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard ARWorldTrackingConfiguration.isSupported else {
            fatalError("""
                ARKit is not available on this device. For apps that require ARKit
                for core functionality, use the `arkit` key in the key in the
                `UIRequiredDeviceCapabilities` section of the Info.plist to prevent
                the app from installing. (If the app can't be installed, this error
                can't be triggered in a production scenario.)
                In apps where AR is an additive feature, use `isSupported` to
                determine whether to show UI for launching AR experiences.
            """) // For details, see https://developer.apple.com/documentation/arkit
        }

        /*
         Start the view's AR session with a configuration that uses the rear camera,
         device position and orientation tracking, and plane detection.
        */
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)

        // Set a delegate to track the number of plane anchors for providing UI feedback.
        sceneView.session.delegate = self
        
        /*
         Prevent the screen from being dimmed after a while as users will likely
         have long periods of interaction without touching the screen or buttons.
        */
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Show debug UI to view performance metrics (e.g. frames per second).
        sceneView.showsStatistics = true
        
//        sceneView.automaticallyUpdatesLighting = false
    }

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		// Pause the view's AR session.
		sceneView.session.pause()
	}
	
    // MARK: - Gesture Methods
    
    // Rotate an object clockwise on Swiping Left in Z plane
    @objc
    func rotateObjectToLeft(_ gestureRecognize: UIGestureRecognizer) {
        let p = gestureRecognize.location(in: sceneView)
        let hitResults = sceneView.hitTest(p, options: [:])
        if hitResults.count > 0 {
            let result = hitResults[0]
            result.node.runAction(SCNAction.rotateBy(x: 0, y: 0, z: -1, duration: 0.25))
        }
    }
    // Rotate an object anticlockwise on Swiping Left in Z plane
    @objc
    func rotateObjectToRight(_ gestureRecognize: UIGestureRecognizer) {
        let p = gestureRecognize.location(in: sceneView)
        let hitResults = sceneView.hitTest(p, options: [:])
        if hitResults.count > 0 {
            let result = hitResults[0]
            result.node.runAction(SCNAction.rotateBy(x: 0, y: 0, z: 1, duration: 0.25))
        }
    }
    // Rotate an object upwards on Swiping Left in Y plane
    @objc
    func rotateObjectUp(_ gestureRecognize: UIGestureRecognizer) {
        let p = gestureRecognize.location(in: sceneView)
        let hitResults = sceneView.hitTest(p, options: [:])
        if hitResults.count > 0 {
            let result = hitResults[0]
            result.node.runAction(SCNAction.rotateBy(x: 0, y: 1, z: 0, duration: 0.25))
        }
    }
    
    // Change the size of object on pinch
    @objc
    func changeScale(_ gestureRecognize: UIPinchGestureRecognizer) {
        let p = gestureRecognize.location(in: sceneView)
        let hitResults = sceneView.hitTest(p, options: [:])
        if hitResults.count > 0 {
            let result = hitResults[0]
            switch gestureRecognize.state {
            case .changed, .ended:
                result.node.scale = SCNVector3(gestureRecognize.scale, gestureRecognize.scale, gestureRecognize.scale)
            default:
                break
            }
        }
    }
        
    @objc
    func highlightObject(_ gestureRecognize: UIGestureRecognizer) {
        segueButton.isHidden = false
        let p = gestureRecognize.location(in: sceneView)
        let hitResults = sceneView.hitTest(p, options: [:])
        if hitResults.count > 0 {
            let result = hitResults[0]
            let material = result.node.geometry!.firstMaterial!
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                material.emission.contents = UIColor.black
                SCNTransaction.commit()
            }
            material.emission.contents = UIColor.red
            SCNTransaction.commit()
            
            if objectOnPathToBeAdded != nil {
                if virtualObjectInstance.virtualObjectCountArray[objectOnPathToBeAdded!].name == "Cube" {
                    virtualObjectInstance.virtualObjects[objectOnPathToBeAdded!].count += 1
                } else if virtualObjectInstance.virtualObjectCountArray[objectOnPathToBeAdded!].name == "Sphere" {
                    virtualObjectInstance.virtualObjects[objectOnPathToBeAdded!].count += 1
                }
            }
            
            if (result.node.parent?.name) != nil {
                let nodeToBeRemoved = (result.node.parent?.name)!
                switch nodeToBeRemoved {
                case "cube" :
                    segueButton.setBackgroundImage(UIImage(named: "cube"), for: .normal)
                    result.node.parent?.removeFromParentNode()
                case "sphere" :
                    segueButton.setBackgroundImage(UIImage(named: "sphere"), for: .normal)
                    result.node.parent?.removeFromParentNode()
                default:
                    break
                }
            }
        
            // result.node.parent?.removeFromParentNode()
            tappedNode?.isHidden = false
        }
    }
}

