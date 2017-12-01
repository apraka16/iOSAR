/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Main view controller for the AR experience.
*/

import UIKit
import SceneKit
import ARKit
import CoreData

/* Protocol added so that TableViewController can communicate when color of an object is chosen
 For implementation of protocol, check VirtualObjectTableViewController */
protocol ColorObjectToVCDelegate {
    func objectColor() -> UIColor
}

class ViewController: UIViewController, VCFinalDelegate, UIPopoverPresentationControllerDelegate {
    
    let levelOfPlay = 15
    var nodesAddedInScene: [SCNNode: vector_float3] = [:]
    
    // MARK: - Instance Variables
    
    // For text to speech
    let speech = Speech()
    
    var arrayFeaturePointDistance: [CGFloat] = []
    
    // Delegate variable used for Protocol
    var delegate: ColorObjectToVCDelegate?
    
    // Sound effect
    var sound = Sounds()
    
    /* Initialize virtual object and fetch the array of all scenarios dependent
     on the level of play*/
    // Instatiate VO
    var virtualObjectInstance = VirtualObjects()
    
    // Get all scenario of level of play
    var scenarios: [(number: Int, shape: String, color: String, score: Int)] {
        get {
            return virtualObjectInstance.getScenarios(expectedLevel: levelOfPlay)
        }
    }
    
    // Generate random scenario for adding nodes in ARSCN
    func generateRandomScenario() -> (number: Int, shape: String, color: String) {
        let randomScenarios = scenarios[randRange(lower: 0, upper: scenarios.count - 1)]
        return (number: randomScenarios.number,
                shape: randomScenarios.shape,
                color: randomScenarios.color)
    }
    
    var material: SCNMaterial?
    var screenCenter: CGPoint {
        return sceneView.center
    }
    
    var randomScenario: (number: Int, shape: String, color: String)?
    
    // Varibles for button image changes
    private var toggleState = 1
    private let imgPlay = UIImage(named: "playBtn")
    private let imgStop = UIImage(named: "stopBtn")
    
    // Controls whether gesture works or not
    var inStateOfPlayForGestureControl = false // Unsure whether this is the swifty way
    
    /* Implementation of ContainerTableView delegate function:
     Check ContainerTableViewController for protocol implementation */
    func passVirtualObject() -> [(name: String, count: Int)] {
        return virtualObjectInstance.virtualObjectsNames
    }
    
    // MARK: - IBOutlets
    
    /* Segue Button at bottom right corner opens tableView (Container...) to keep score of
     swiped down objects from main view */
    // Outlet for changing background image of button depending on the object which is swiped down
    @IBOutlet weak var segueButton: UIButton!
    
    // Button for changing mode to Playing - toggling image underlying the button
    @IBOutlet weak var playButton: UIButton!
    
    
    // Method to hide/ unhide set of buttons/ object depending on play mode or else
    func inStateOfPlay(playing: Bool) {
        if playing {
            inStateOfPlayForGestureControl = true
            playButton.setBackgroundImage(imgStop, for: .normal)
            randomScenario = generateRandomScenario()
            // Speech to start play mode
            DispatchQueue.global(qos: .userInitiated).async {
                self.speech.say(text: self.speech.welcomeText)
                self.speech.sayFind(number: (self.randomScenario?.number)!,
                                    color: (self.randomScenario?.color)!,
                                    shape: (self.randomScenario?.shape)!)
            }
            
            for nodeInScene in nodesAddedInScene {
//                nodeInScene.key.childNodes.first?.opacity = 0.0
//                let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
                
//                let cubeNode = SCNNode(geometry: cube)
                
//                let physicsBody = SCNPhysicsBody(
//                    type: .dynamic,
//                    shape: SCNPhysicsShape(node: cubeNode, options: nil))
//                physicsBody.mass = 1.25
//                physicsBody.restitution = 0.1
//                physicsBody.friction = 0.8
//                physicsBody.rollingFriction = 1.0
//                physicsBody.damping = 0.8
//                physicsBody.angularDamping = 0.8
//                cubeNode.physicsBody = physicsBody
//
//                cubeNode.simdPosition = float3(nodeInScene.value.x,
//                                               nodeInScene.value.y + 1.0,
//                                               nodeInScene.value.z)
//                nodeInScene.key.addChildNode(cubeNode)
                
//                let when = DispatchTime.now() + 0.5
                
                for object in scenarios {
                    let shape = virtualObjectInstance.createNodes(from: object.shape,
                                                      with: virtualObjectInstance.virtualObjectsColors[object.color]!)
                    
                    let physicsBody = SCNPhysicsBody(
                        type: .dynamic,
                        shape: SCNPhysicsShape(node: shape, options: nil))
                    physicsBody.mass = 1.25
                    physicsBody.restitution = 0.1
                    physicsBody.friction = 0.8
                    physicsBody.rollingFriction = 1.0
                    physicsBody.damping = 0.8
                    physicsBody.angularDamping = 0.8
                    shape.physicsBody = physicsBody
                    
                    nodeInScene.key.addChildNode(shape)
                    shape.simdPosition = float3(nodeInScene.value.x,
                                                nodeInScene.value.y + 1.0,
                                                nodeInScene.value.z)
                }
                
//                for shape in shapes {
//                    DispatchQueue.main.asyncAfter(deadline: when, execute: {
//                        nodeInScene.key.addChildNode(shape)
//                        shape.simdPosition = float3(nodeInScene.value.x,
//                                                    nodeInScene.value.y + 1.0,
//                                                    nodeInScene.value.z)
//                    })
//                }
            }
            
        } else {
            inStateOfPlayForGestureControl = false
            playButton.setBackgroundImage(imgPlay, for: .normal)
        }
    }
    
    private func addPhysics(to node: SCNNode) -> SCNNode {
        let physicsBody = SCNPhysicsBody(
            type: .dynamic,
            shape: SCNPhysicsShape(node: node, options: nil))
        physicsBody.mass = 1.25
        physicsBody.restitution = 0.1
        physicsBody.friction = 0.8
        physicsBody.rollingFriction = 1.0
        physicsBody.damping = 0.8
        physicsBody.angularDamping = 0.8
        node.physicsBody = physicsBody
        return node
    }
    
    // Info label and view
    // @TODO: Hide label when play mode is operational
    @IBOutlet weak var sessionInfoView: UIView!
    @IBOutlet weak var sessionInfoLabel: UILabel!
    
    // Main AR Scene View for rendering content
    @IBOutlet weak var sceneView: ARSCNView! {
        didSet {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(collectObject(_:)))
            tapGesture.numberOfTapsRequired = 1
            tapGesture.numberOfTouchesRequired = 1
            sceneView.addGestureRecognizer(tapGesture)
                  
        }
    }
    
    // MARK: - IBActions
    
    // Reset button - top right corner resets AR rendering
    @IBAction func reset(_ sender: UIButton) {
        sender.showsTouchWhenHighlighted = true
        resetTracking()
    }
    
    
    /* Button to select play mode. Under play mode:
     - Info and add buttons are hidden
     - Image underlying the button toggle play/ stop images (imgPlay and imgStop - declared in vars)*/
    @IBAction func play(_ sender: UIButton) {
        if toggleState == 1 {
            toggleState = 2
            playButton.setBackgroundImage(imgStop, for: .normal)
            inStateOfPlayForGestureControl = true // Unsure whether this is the swifty way
            inStateOfPlay(playing: true)
            
        } else {
            toggleState = 1
            playButton.setBackgroundImage(imgPlay, for: .normal)
            inStateOfPlayForGestureControl = false // Unsure whether this is the swifty way
            inStateOfPlay(playing: false)
        }
    }
    
    
    // Segue button to segue to ContainerTableView
    @IBAction func btnPerformSeguePressed(_ sender: UIButton) {
        performSegue(withIdentifier: "ARSCNToTabView", sender: nil)
    }
    
    // Other Segue preparations
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destinationViewController = segue.destination
        if let navigationController = destinationViewController as? UINavigationController {
            destinationViewController = navigationController.visibleViewController
                ?? destinationViewController
        }
        
        if let TableViewController = destinationViewController as? ContainerTableViewController {
            TableViewController.delegate = self
            if let popoverPresentationController = segue.destination.popoverPresentationController {
                popoverPresentationController.delegate = self
            }
        }      
    }
    
    
    // Function so that popover doesn't adapt to cover full screen on iphones
    func adaptivePresentationStyle(for controller: UIPresentationController,
                                   traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        if traitCollection.verticalSizeClass == .compact {
            return .none
        } else {
            return .none
        }
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let crosshair = Crosshairs()
        crosshair.displayAsBillboard()
        
        sceneView.pointOfView?.addChildNode(crosshair)

    }
    
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
            """)
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
        
        // Debug options - for showing feature points (yellow dots) and world origin axes
//        sceneView.debugOptions = [
//            ARSCNDebugOptions.showFeaturePoints,
//            ARSCNDebugOptions.showWorldOrigin
//        ]
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
        self.sceneView.antialiasingMode = .multisampling4X

    }
    
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		// Pause the view's AR session. //
		sceneView.session.pause()
	}
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    private func randRange (lower: Int, upper: Int) -> Int {
        return Int(UInt32(lower) + arc4random_uniform(UInt32(upper) - UInt32(lower) + 1))
    }
    
}


/// - Tag: Animation code - not useful, since object is removed before animation can take effect
// let material = result.node.geometry!.firstMaterial!
// SCNTransaction.begin()
// SCNTransaction.animationDuration = 0.5
// SCNTransaction.completionBlock = {
//    SCNTransaction.begin()
//    SCNTransaction.animationDuration = 0.5
//    material.emission.contents = UIColor.black
//    SCNTransaction.commit()
// }
// material.emission.contents = UIColor.red
// SCNTransaction.commit()


