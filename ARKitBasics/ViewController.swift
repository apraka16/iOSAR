/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 Main view controller for the AR experience.
 */

import UIKit
import SceneKit
import ARKit
import CoreData

/*
 Protocol added so that TableViewController can communicate when color of an object is chosen
 For implementation of protocol, check VirtualObjectTableViewController
 */
protocol ColorObjectToVCDelegate {
    func objectColor() -> UIColor
}

class ViewController: UIViewController,
VCFinalDelegate,
UIPopoverPresentationControllerDelegate {
    
    /*!
     @method passVirtualObject
     @abstract Implementation of ContainerTableView delegate function
     @param none
     @discussion Check ContainerTableViewController for protocol implementation
     */
    func passVirtualObject() -> [(name: String, count: Int)] {
        return virtualObjectInstance.virtualObjectsNames
    }
    
    // MARK: - Instance Variables
    
    // Configurable complexity of the game
    let levelOfPlay = 10   // 1, 2, 3, 4, 5, 6, 8, 9, 10, 12, 15
    let sceneComplexity = 0.5  // More complex, closer to 1, less complex closer to 0.
    
    // This variable stores a dictionary of the root node which is added by auto-plane
    // detection in ARSCN Delegate and corresponding center of the node and extent, i.e.,
    // width(x) and height(z) of the PlaneAnchorNode which is added upon the root node.
    var nodesAddedInScene: [SCNNode: [vector_float3]] = [:]
    
    
    // Instantiate Speech Class for text to speech conversion
    let speech = Speech()
    
    // Instantiate Sound Class for playing short mp3 files
    var sound = Sounds()
    
    // For feature point detection so as to move the crosshair distance away from camera
    var arrayFeaturePointDistance: [CGFloat] = []
    
    // Delegate variable used for Protocol
    var delegate: ColorObjectToVCDelegate?
    
    
    /*
     Initialize virtual object and fetch the array of all scenarios dependent
     on the level of play
     */
    // Instatiate VO
    var virtualObjectInstance = VirtualObjects()
    
    // Fetch all scenarios corresponding to a certain "levelOfPlay"
    var scenarios: [(number: Int, shape: String, color: String, score: Int)] {
        get {
            return virtualObjectInstance.getScenarios(expectedLevel: levelOfPlay)
        }
    }
    
    
    // Generate random scenario from all scenarios to be used while creating
    // challenges and scene for the user.
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
    
    // Varibles for button image changes
    let imgPlay = UIImage(named: "playBtn")
    private let imgStop = UIImage(named: "stopBtn")
    
    // Controls whether gesture works or not
    var inStateOfPlay = false 
    
    // MARK: - IBOutlets
    
    /*
     Segue Button at bottom right corner opens tableView (Container...) to keep score of
     swiped down objects from main view
     */
    // Outlet for changing background image of button depending on the object which is swiped down
    @IBOutlet weak var segueButton: UIButton!
    
    // Button for changing mode to Playing - toggling image underlying the button
    @IBOutlet weak var playButton: UIButton!
    
    @IBAction func play(_ sender: UIButton) {
        deleteAllObjects()
        if sender.backgroundImage(for: .normal) == imgPlay {
            if !inStateOfPlay {
                startPlay(playing: true)
            }
        } else {
            DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                self?.speech.sayWithInterruption(text: "Hit play for next")
            }
            inStateOfPlay = false
            sender.setBackgroundImage(imgPlay, for: .normal)

        }
    }
    
    /* User should be provided with audio as well as visual guide as to what the target
     is. Hence, on the bottom-right, 'display' is a SCNView which shows the target object
     when play mode is on. */
    // Outlet for 'display'
    @IBOutlet weak var display: SCNView!
    
    // Check whether there is an existing object in display scene and remove that node so
    // that nodes are removed there there is no need to keep them in memory
    private func addNodeToDisplay(node: SCNNode) {
        removeNodeFromDisplay()
        // Scale factor and angles have been chosen after some empirical observations.
        // @TODO: Needs better visuals here.
        display.scene?.rootNode.addChildNode(node)
        node.scale = SCNVector3(x: 2.8, y: 2.8, z: 2.8)
        node.eulerAngles.x = .pi / 8
    }
    
    // Separate nodes are created specifically for the purpose of 'display'
    private func createNodeForDisplay() -> SCNNode {
        return virtualObjectInstance.createNodes(from: (chosenScenarioForChallenge?.shape)!,
                                                 with: virtualObjectInstance.virtualObjectsColors[
                                                    (chosenScenarioForChallenge?.color)!]!)
    }
    
    // Remove nodes from 'display' in case there already is node in the display
    // This is used when adding node to 'display' as well as when correct object is chosen
    // from tap gesture
    
    func removeNodeFromDisplay() {
        if let countOfChildNodes = display.scene?.rootNode.childNodes.count {
            if countOfChildNodes >= 2 {
                display.scene?.rootNode.childNodes.last?.removeFromParentNode()
            }
        }
    }
    
    
    var chosenScenarios: [(number: Int, shape: String, color: String)] = []
    var chosenScenarioForChallenge: (number: Int, shape: String, color: String)?
    
    /*
     Main method which controls the rhythm of the whole game. Game starts when
     certain number of planes are detected and objects are placed corresponding
     to the anchors therein. Game ends when use through tap gesture is able to
     collect the object as required to complete the challenge. Game restarts
     again after that. */
    
    // Struct with static vars to use when calculating optimum number of tiles to
    // fit a detected surface.
    private struct OptimumTiles {
        static let halfTileSize: Float = 0.1
        static let fullTileSize: Float = 0.2
        static let margin: Float = 0.1
    }
    
    func startPlay(playing: Bool) {
        if playing {
            
            // To make sure tap gesture is operative only when user is on play more
            inStateOfPlay = true
            
            // Setting background image to "Stop" as soon as user enters the play more
            playButton.setBackgroundImage(imgStop, for: .normal)
            
            /*
             Add randomly generated shapes in an optimum fashion to the plane Nodes
             
             PlaneAnchorNode:
             ________________________
             |     1     2     3      |
             |    ____|_____|____     |  // 5 is the center. All other tiles spawn
             |     4  |  5  |  6      |  // around center.
             |    ____|_____|____     |
             |     7  |  8  |  9      |
             |________________________|
             
             PlaneAnchor node must be fitted with tiles measuring 0.1*0.1, with central
             tile covering center of the PlaneAnchorNode. In order to make sure of this,
             we use the func findOptimumNumberOfNodesToFit. After we obtain the number
             of tile it will take to fill the PlaneAnchorNode, we can safely place
             random objects on each tile, without any interaction between them.
             */
            
            
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.sound.playSound(named: "thud")
                for nodeInScene in (self?.nodesAddedInScene)! {
//                    nodeInScene.key.childNodes.first?.opacity = 0.0
                    let optimumFit = self?.findOptimumNumberOfNodesToFit(extent: nodeInScene.value.last!)
                    for Z in (-(optimumFit?.alongZ)!/2)...((optimumFit?.alongZ)!/2) {
                        for X in (-(optimumFit?.alongX)!/2)...((optimumFit?.alongX)!/2) {
                            if (self?.generateRandomBool(with: (self?.sceneComplexity)!))! {
                                // Generate random shape and add to array
                                let shape = self?.generateShapesRandomly()
                                // Add shapes to the center as calculated by optimum node function
                                DispatchQueue.main.async {
                                    nodeInScene.key.addChildNode(shape!)
                                    shape?.simdPosition = float3(
                                        (nodeInScene.value.first?.x)! + Float(X)*(0.2 + OptimumTiles.margin),
                                        (nodeInScene.value.first?.y)!,
                                        (nodeInScene.value.first?.z)! + Float(Z)*(0.2 + OptimumTiles.margin)
                                    )
                                }
                            }
                        }
                    }
                }
                self?.speech.say(text: (self?.speech.welcomeText)!)
                
                // Chosen Scenario is used for actual challenge
                self?.chosenScenarioForChallenge = self?.chosenScenarios[
                    (self?.randRange(lower: 0, upper: (self?.chosenScenarios.count)! - 1))!
                ]
                
                self?.speech.sayFind(color: (self?.chosenScenarioForChallenge?.color)!,
                                    shape: (self?.chosenScenarioForChallenge?.shape)!
                )
                
                // Add Chosen object to 'display' view
                if let nodeForDisplay = self?.createNodeForDisplay() {
                    self?.addNodeToDisplay(node: nodeForDisplay.childNodes.last!)
                }
                
                DispatchQueue.main.async {
                    self?.audio.isHidden = false
                }
            }
        } else {
            inStateOfPlay = false
            playButton.setBackgroundImage(imgPlay, for: .normal)
            animationForObjects()
            audio.isHidden = true
        }
    }
    
    // Generate bool basis probability parameter. Usage: if one wants to generate true
    // with 80% probability, one will use 0.8 in place of probability parameter.
    private func generateRandomBool(with probability: Double) -> Bool {
        let randomNumberBetweenOneAndTen = randRange(lower: 1, upper: 10)
        // Note that Int casting will always round down
        if randomNumberBetweenOneAndTen <= Int(10*probability) {
            return true
        } else {
            return false
        }
    }
    
    // Create shapes sequentially and add to randomScenario array
    private func generateShapesRandomly() -> SCNNode {
        let randomScenario = generateRandomScenario()
        chosenScenarios.append(randomScenario)
        let shape = virtualObjectInstance.createNodes(
            from: randomScenario.shape,
            with: virtualObjectInstance.virtualObjectsColors[randomScenario.color]!
        )
        return shape
    }

    
    // After a run of the game, clears all objects and empties the array of scenarios used in
    // the game
    private func animationForObjects() {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            for node in (self?.nodesAddedInScene.keys)! {
                if node.childNodes.count > 1 {
                    // Index being started at 1, since planeAnchors should not be animated
                    for index in 1...node.childNodes.count - 1 {
                        // user tapped node is being named "target" in gesture controller
                        if node.childNodes[index].childNodes.first?.name == "target" {
                            // user tapped node should run transition, rotation and fading animation
                            self?.riseUpSpinAndFadeAnimation(on: node.childNodes[index])
                        } else {
                            // All other nodes should run fading animation
                            self?.fadeAnimation(on: node.childNodes[index])
                        }
                    }
                }
            }
        }
    }

    
    // Delete all nodes except the planeAnchor node.
    // Empty chosenScenario array
    private func deleteAllObjects() {
        DispatchQueue.global(qos: .userInteractive).async {
            if self.chosenScenarios.count > 0 {
                self.chosenScenarios.removeAll()
                for node in self.nodesAddedInScene.keys {
                    while node.childNodes.count > 1 {
//                        node.childNodes.last?.removeAllAnimations()
                        node.childNodes.last?.removeFromParentNode()
                    }
                }
            }
        }
    }
    
    
    // Find number of nodes which can be fitted along X and Z directions on the planeAnchor
    private func findOptimumNumberOfNodesToFit(extent: vector_float3) -> (alongX: Int, alongZ: Int) {
        var numberOfNodesAlongX =
            Int((extent.x / 2 - OptimumTiles.halfTileSize - OptimumTiles.margin)
                / (OptimumTiles.fullTileSize + 2 * OptimumTiles.margin)) * 2 + 1
        
        var numberOfNodesAlongZ =
            Int((extent.z / 2 - OptimumTiles.halfTileSize - OptimumTiles.margin)
                / (OptimumTiles.fullTileSize + 2 * OptimumTiles.margin)) * 2 + 1
        
        // Make sure atleast there is one node along both X and Z, which is actually valid, since
        // bare minimum one object can be placed on the center of the plane, which is what we are
        // ensuring
        if numberOfNodesAlongX < 1 { numberOfNodesAlongX = 1 }
        if numberOfNodesAlongZ < 1 { numberOfNodesAlongZ = 1 }
        
        return (alongX: numberOfNodesAlongX, alongZ: numberOfNodesAlongZ)
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
        resetTracking()
    }
    
    
    @IBOutlet weak var audio: UIButton!
    
    @IBAction func repeatChallengeAudio(_ sender: UIButton) {
        if speech.isSpeaking {
            speech.stopSpeaking(at: AVSpeechBoundary.immediate)
        }
        speech.sayFind(color: (chosenScenarioForChallenge?.color)!,
                            shape: (chosenScenarioForChallenge?.shape)!
        )
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
    
    private func setUpDisplay() {
        display.scene = SCNScene()
        
        // Create and add a camera to the scene
        let cameraNode = SCNNode(); cameraNode.camera = SCNCamera()
        display.scene?.rootNode.addChildNode(cameraNode)
        
        // Place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0.25, z: 1.5)
        display.autoenablesDefaultLighting = true
        display.antialiasingMode = .multisampling4X
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpDisplay()
        
        let crosshair = Crosshairs()
        crosshair.displayAsBillboard()
        playButton.isHidden = true
        audio.isHidden = true
        
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
        sceneView.antialiasingMode = .multisampling4X
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's AR session. //
        sceneView.session.pause()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func randRange (lower: Int, upper: Int) -> Int {
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


