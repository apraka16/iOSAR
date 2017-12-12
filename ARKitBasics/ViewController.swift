/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 Main view controller for the AR experience.
 */

import UIKit
import SceneKit
import ARKit
import CoreData


class ViewController: UIViewController, UITabBarControllerDelegate {
    
    // MARK: - Instance Variables
    let defaults = UserDefaults.standard
    
    var indexOfPoolProbabilities: Int = 1
    var countOfConsecutiveWins: Int = 1
    var countOfConsecutiveLosses: Int = 1
    var individualProbabilities: [Double] {
        get {
            return virtualObjectInstance.arrayOfProbabilities[indexOfPoolProbabilities - 1]
        }
    }
    
    // Configurable complexity of the game
    var sceneComplexity = 0.2  // More complex, closer to 1, less complex closer to 0.
    
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
    
    // If user goes to Settings Tab Bar, reset the whole game
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if viewController.tabBarItem.tag == 2 {
            self.resetTracking()
        }
    }
    
    /*
     Initialize virtual object and fetch the array of all scenarios dependent
     on the level of play
     */
    // Instatiate VO
    var virtualObjectInstance = VirtualObjects()
    
    // Generate random scenario from all scenarios to be used while creating
    // challenges and scene for the user.
    func generateRandomScenario() -> (shape: String, color: String) {
        return virtualObjectInstance.generateObject(using: individualProbabilities)
    }
    
//    var material: SCNMaterial?
    var screenCenter: CGPoint {
        return sceneView.center
    }
    
    // Varibles for button image changes
    let imgPlay = UIImage(named: "playBtn")
    private let imgStop = UIImage(named: "stopBtn")
    
    // Controls whether gesture works or not
    var inStateOfPlay = false 
    
    
    // MARK: - IBOutlets
    
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
        virtualObjectInstance.adjustNodes(node: node)
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
        display.scene?.rootNode.childNodes.filter
            { $0.name != "camera" }.forEach { $0.removeFromParentNode() }
    }
    
    var chosenScenarios: [(shape: String, color: String)] = []
    var chosenScenarioForChallenge: (shape: String, color: String)?
    
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
             
             If the sceneComplexity is 0.6, generateRandomBool() will return true with 0.6
             probability. If bool returns true, object will be placed otherwise it will not.
             First off, one object will be placed on all detected surfaces in the center
             irrespective of sceneComplexity and randomBool. Then, function will start from
             tile 1 (as shown above) traverse across horizontal and vertical and depending
             on result of randomBool with sceneComplexity place random 3D objects on all tiles
             
             optimumNodeToFit is used to find the total number of tiles measuring a certain
             dimension, which can fit the detected surface. 
             */
            
            
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.sound.playSound(named: "thud")
                for nodeInScene in (self?.nodesAddedInScene)! {
                    nodeInScene.key.childNodes.first?.opacity = 0.0
                    let optimumFit = self?.findOptimumNumberOfNodesToFit(extent: nodeInScene.value.last!)
                    for Z in (-(optimumFit?.alongZ)!/2)...((optimumFit?.alongZ)!/2) {
                        for X in (-(optimumFit?.alongX)!/2)...((optimumFit?.alongX)!/2) {
                            
                            // All planes to have at least on object which will be at the center.
                            // Hence, sceneComplexity var is not used to place object(s) at the
                            // center
                            if Z == 0 && X == 0 {
                                let shape = self?.generateShapesRandomly()
                                DispatchQueue.main.async {
                                    nodeInScene.key.addChildNode(shape!)
                                    shape?.simdPosition = float3((nodeInScene.value.first?.x)!,
                                                                 (nodeInScene.value.first?.y)!,
                                                                 (nodeInScene.value.first?.z)!)
                                }
                            }
                                
                            // After placing objects on center of each detected surfaces, sceneComplexity
                            // along with randomBool is used to add objects across the detected surfaces
                            // other than centers of the detected surfaces.
                            else if (self?.generateRandomBool(with: (self?.sceneComplexity)!))! {
                                // Generate random shape and add to array
                                let shape = self?.generateShapesRandomly()
                                // Add shapes to the center as calculated by optimum node function
                                DispatchQueue.main.async {
                                    nodeInScene.key.addChildNode(shape!)
                                    shape?.simdPosition = float3(
                                        (nodeInScene.value.first?.x)! +
                                            Float(X)*(OptimumTiles.fullTileSize + OptimumTiles.margin),
                                        (nodeInScene.value.first?.y)!,
                                        (nodeInScene.value.first?.z)! +
                                            Float(Z)*(OptimumTiles.fullTileSize + OptimumTiles.margin)
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
                
                node.childNodes.filter { $0.name != "target" && $0.name != "anchorPlane" }.forEach {
                    $0.removeFromParentNode()
                }
                
                node.childNodes.filter { $0.name == "target" }.forEach {
                    self?.riseUpSpinAndFadeAnimation(on: $0)
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
                    node.childNodes.filter { $0.name != "anchorPlane" }.forEach {
                        $0.removeFromParentNode()
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
    
    // Set up 'display' view, add camera, and other settings
    private func setUpDisplay() {
        display.scene = SCNScene()
        
        // Create and add a camera to the scene
        let cameraNode = SCNNode(); cameraNode.camera = SCNCamera()
        display.scene?.rootNode.addChildNode(cameraNode)
        cameraNode.name = "camera"
        
        // Place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0.25, z: 1.5)
        display.autoenablesDefaultLighting = true
        display.antialiasingMode = .multisampling4X
    }
    
    // Remove all nodes from 'display'
    private func clearDisplay() {
        for child in (display.scene?.rootNode.childNodes)! {
            child.removeFromParentNode()
        }
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        print(AVSpeechSynthesisVoice.speechVoices())
        self.tabBarController?.delegate = self
        
        let crosshair = Crosshairs()
        crosshair.displayAsBillboard()
        playButton.isHidden = true
        audio.isHidden = true
        
        sceneView.pointOfView?.addChildNode(crosshair)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpDisplay()
        prepareForGameLevelLoad()
    }
    
    /*
     When view is appearing, indexOfPoolProbabilities, sceneComplexity, countOfConsecutiveWins,
     countOfConsecutiveLosses will be loaded from userDefaults, in case there are no such
     objects in userDefaults such as when the app is user for the first time, default values
     (mimimum allowed) will be set for these variables.
     In case user resets the game levels, there 4 objects will be removed from userDefaults, so
     that it assigns defaults for these vars when view is appearing.
     
     Note: minimum values for indexOfPoolProbabilities, countOfConsecutiveWins,
     countOfConsecutiveLosses are kept at 1, since userDefaults in case non-existent returns
     a value of 0, which is why we can't set it as 0 which would have made logical sense.
     */
    private func prepareForGameLevelLoad() {
        if Settings.sharedInstance.resetLevel {
            defaults.removeObject(forKey: "countOfConsecutiveWins")
            defaults.removeObject(forKey: "countOfConsecutiveLosses")
            defaults.removeObject(forKey: "indexOfPoolProbabilities")
            defaults.removeObject(forKey: "sceneComplexity")
        }
        
        let index = defaults.integer(forKey: "indexOfPoolProbabilities")
        if index == 0 {
            indexOfPoolProbabilities = 1
        } else {
            indexOfPoolProbabilities = index
        }
        
        let density = defaults.double(forKey: "sceneComplexity")
        if density > 0.0 {
            sceneComplexity = density
        } else {
            sceneComplexity = 0.2
        }
        
        let countWins = defaults.integer(forKey: "countOfConsecutiveWins")
        if countWins == 0 {
            countOfConsecutiveWins = 1
        } else {
            countOfConsecutiveWins = countWins
        }
        
        let countLosses = defaults.integer(forKey: "countOfConsecutiveLosses")
        if countLosses == 0 {
            countOfConsecutiveLosses = 1
        } else  {
            countOfConsecutiveLosses = countLosses
        }        
    }
    
    /// - Tag: StartARSession
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        speech.say(text: "We will detect a few surfaces. Please move your device around")
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
        clearDisplay()
    }
    
    // Helper function to generate random Integers between two Ints both ends inclusive
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


