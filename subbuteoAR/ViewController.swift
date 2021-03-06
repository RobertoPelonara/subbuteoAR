/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Main view controller for the AR experience.
*/

import ARKit
import SceneKit
import UIKit

class ViewController: UIViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet var sceneView: VirtualObjectARView!
    
    @IBOutlet weak var addObjectButton: UIButton!
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!

    @IBOutlet weak var placeFieldOutlet: UIButton!

    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var goalImage: UIImageView!
    
    var canMoveField = true
    var settingFieldPosition = false
    
    // MARK: - UI Elements
    var focusSquare = FocusSquare()
    
    /// The view controller that displays the status and "restart experience" UI.
    lazy var statusViewController: StatusViewController = {
        return childViewControllers.lazy.flatMap({ $0 as? StatusViewController }).first!
    }()
	
    
    var touchStartPosition: SCNVector3?
    var touchEndPosition: SCNVector3?
    var touchStartTime: TimeInterval?
    var touchEndTime: TimeInterval?
    var currentObject: SCNNode?
    
    var velocityToApply: Float = 1.0
    var touchStartPositionScreen: CGPoint?
    var touchEndPositionScreen: CGPoint?
    
    var isCurrentObjectMoving: Bool = false
    
    var bNode: SCNNode?
    var gNode: SCNNode?
    
    var gameSet = false
    
    @IBOutlet weak var awayScoreView: UIImageView!
    @IBOutlet weak var homeScoreView: UIImageView!
    @IBOutlet weak var scoreVIew: UIImageView!
    
    // MARK: - ARKit Configuration Properties
    
    /// A type which manages gesture manipulation of virtual content in the scene.
    lazy var virtualObjectInteraction = VirtualObjectInteraction(sceneView: sceneView)
    
    /// Coordinates the loading and unloading of reference nodes for virtual objects.
    let virtualObjectLoader = FieldLoader()
    
    /// Marks if the AR experience is available for restart.
    var isRestartAvailable = true
    
    /// A serial queue used to coordinate adding or removing nodes from the scene.
    let updateQueue = DispatchQueue(label: "com.narax.subbuteo")
    
    var screenCenter: CGPoint {
        let bounds = sceneView.bounds
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    /// Convenience accessor for the session owned by ARSCNView.
    var session: ARSession {
        return sceneView.session
    }
    
    // MARK: - View Controller Life Cycle
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.session.delegate = self

        // Set up scene content.
        setupCamera()
        sceneView.scene.rootNode.addChildNode(focusSquare)
        sceneView.scene.physicsWorld.contactDelegate = self
        sceneView.debugOptions = [.showPhysicsShapes]
//        Set MPC Manager delegate
        MPCManager.shared.delegate = self
        
          // Hook up status view controller callback(s).
        statusViewController.restartExperienceHandler = { [unowned self] in
            self.restartExperience()
            
            // Set up "Ready" button
            self.placeFieldOutlet.layer.cornerRadius = 500

        }
        
        //"GOAL" image alpha=0 (for animation)
        goalImage.alpha = 0
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showVirtualObjectSelectionViewController))
        // Set the delegate to ensure this gesture is only used when there are no virtual objects in the scene.
        tapGesture.delegate = self
        sceneView.addGestureRecognizer(tapGesture)
        
        self.navigationController?.isNavigationBarHidden = true
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		// Prevent the screen from being dimmed to avoid interuppting the AR experience.
		UIApplication.shared.isIdleTimerDisabled = true

        // Start the `ARSession`.
        resetTracking()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

        session.pause()
	}

    // MARK: - Scene content setup

    func setupCamera() {
        guard let camera = sceneView.pointOfView?.camera else {
            fatalError("Expected a valid `pointOfView` from the scene.")
        }

        /*
         Enable HDR camera settings for the most realistic appearance
         with environmental lighting and physically based materials.
         */
//        camera.exposureOffset = -1
//        camera.minimumExposure = -1
//        camera.maximumExposure = 3
    }

    // MARK: - Session management
    
    /// Creates a new AR configuration to run on the `session`.
	func resetTracking() {
		virtualObjectInteraction.selectedObject = nil
		
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
		session.run(configuration, options: [.resetTracking, .removeExistingAnchors])

        statusViewController.scheduleMessage("FIND A SURFACE TO PLACE AN OBJECT", inSeconds: 7.5, messageType: .planeEstimation)
	}
    
    @IBAction func placeFieldAction(_ sender: Any) {
        
        guard let fieldNode = sceneView.scene.rootNode.childNode(withName: "campo", recursively: true) else {return}
        
      
        canMoveField = !canMoveField
        virtualObjectInteraction.canInteractWithObject = canMoveField
        
        fieldNode.childNode(withName: "field", recursively: true)?.geometry?.materials.first?.transparency = 1
        
//        self.sceneView.session.setWorldOrigin(relativeTransform: (fieldNode.parent?.simdWorldTransform)!)
//        
//        fieldNode.parent?.simdWorldTransform = sceneView.scene.rootNode.simdWorldTransform
    
        for recognizer in sceneView.gestureRecognizers! {
            recognizer.cancelsTouchesInView = false
        }
        
        (UIApplication.shared.delegate as! AppDelegate).gameManager = GameManager.init(scene: self.sceneView.scene)
        
        placeFieldOutlet.isHidden = true
        
        containerView.isHidden = true
        scoreVIew.isHidden = false
        awayScoreView.isHidden = false
        homeScoreView.isHidden = false
        
    }
    
    // MARK: - Focus Square

    func updateFocusSquare() {
        let isObjectVisible = virtualObjectLoader.loadedObjects.contains { object in
            return sceneView.isNode(object, insideFrustumOf: sceneView.pointOfView!)
        }
        
        if isObjectVisible {
            focusSquare.hide()
        } else {
            focusSquare.unhide()
            statusViewController.scheduleMessage("TRY MOVING LEFT OR RIGHT", inSeconds: 5.0, messageType: .focusSquare)
        }
		
		if let result = self.sceneView.smartHitTest(screenCenter) {
			updateQueue.async {
				self.sceneView.scene.rootNode.addChildNode(self.focusSquare)
				let camera = self.session.currentFrame?.camera
				self.focusSquare.state = .detecting(hitTestResult: result, camera: camera)
			}
		} else {
			updateQueue.async {
				self.focusSquare.state = .initializing
				self.sceneView.pointOfView?.addChildNode(self.focusSquare)
			}
			self.addObjectButton.isHidden = true
			return
		}
		
        if settingFieldPosition == false {addObjectButton.isHidden = false}
        statusViewController.cancelScheduledMessage(for: .focusSquare)
	}
    
    // MARK: - Error handling
    
    func displayErrorMessage(title: String, message: String) {
        // Blur the background.
        blurView.isHidden = false
        
        // Present an alert informing about the error that has occurred.
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
            self.blurView.isHidden = true
            self.resetTracking()
        }
        alertController.addAction(restartAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    func goal (_ team: Turn){
        guard let manager = (UIApplication.shared.delegate as! AppDelegate).gameManager else {return}
        
        switch team {
        case .home:
            print("goal home!")
            if manager.scoreHome < 3 {manager.scoreHome += 1} else {return}
            DispatchQueue.main.async {
                self.homeScoreView.image = manager.scoreGoal[manager.scoreHome]
            }
        case .away:
            print("goal away!")
            if manager.scoreAway < 3 {manager.scoreAway += 1} else {return}
            DispatchQueue.main.async {
                self.awayScoreView.image = manager.scoreGoal[manager.scoreAway]
            }
        }
        
        print("points: \(manager.scoreHome) - \(manager.scoreAway)")
        
        self.goalImage.isHidden = false
        
        DispatchQueue.main.async {
            UIImageView.animate(withDuration: 1.5, animations: {
                self.goalImage.alpha = 1
            })
            UIImageView.animate(withDuration: 1.5, delay: 2, animations: {
                self.goalImage.alpha = 0
            }, completion: { (finished) in
                self.goalImage.isHidden = finished
            })
        }
    }

}
