/*
See LICENSE folder for this sample’s licensing information.

Abstract:
UI Actions for the main view controller.
*/

import UIKit
import SceneKit

extension ViewController: UIGestureRecognizerDelegate {
    
    enum SegueIdentifier: String {
        case showObjects
    }
    
    // MARK: - Interface Actions
    
    /// Displays the `VirtualObjectSelectionViewController` from the `addObjectButton` or in response to a tap gesture in the `sceneView`.
    @IBAction func showVirtualObjectSelectionViewController() {
        // Ensure adding objects is an available action and we are not loading another object (to avoid concurrent modifications of the scene).
        guard !addObjectButton.isHidden && !virtualObjectLoader.isLoading else { return }
        
        if focusSquare.isOpen {
            return
        }
        
        
        let modelsURL = Bundle.main.url(forResource: "Models.scnassets/campo", withExtension: "scn")!
        
       let virtualObject = Field.init(url: modelsURL)
        
        virtualObjectLoader.loadVirtualObject(virtualObject!, loadedHandler: { [unowned self] loadedObject in
            DispatchQueue.main.async {
                self.hideObjectLoadingUI()
                self.placeVirtualObject(loadedObject)
                loadedObject.childNode(withName: "floor", recursively: true)?.categoryBitMask = 2
                (UIApplication.shared.delegate as! AppDelegate).gameManager = GameManager.init(scene: self.sceneView.scene)
                
                //place goals
                let field = loadedObject.childNode(withName: "campo", recursively: true)
                guard let box = field?.boundingBox else {print("try again: goals"); return}
                let fieldHeight = box.max.y - box.min.y
                let fieldWidth = box.max.x - box.min.x
                let halfFieldSize = CGSize(width: CGFloat((fieldWidth / 2) * 0.9),
                                           height: CGFloat(((fieldHeight / 2) * 0.75) / 1.75))
                
                let goalPositionX: Float = 0.8
                let positionToApplyHome = float3.init(x: goalPositionX * Float(halfFieldSize.width),
                                                  y: 0,
                                                  z: 0)
                let positionToApplyAway = float3.init(x: positionToApplyHome.x * -1,
                                                      y: 0,
                                                      z: 0)
                
                let goalHomeScene = SCNScene(named: "Models.scnassets/Players + goal/goal.scn")
                let goalAwayScene = SCNScene(named: "Models.scnassets/Players + goal/goal.scn")
                let goalHomeNode = goalHomeScene?.rootNode.childNode(withName: "goal", recursively: true)
                let goalAwayNode = goalAwayScene?.rootNode.childNode(withName: "goal", recursively: true)
                goalAwayNode?.eulerAngles.z = .pi / 2
                goalHomeNode?.simdPosition = positionToApplyHome
                goalAwayNode?.simdPosition = positionToApplyAway
                
                self.sceneView.scene.rootNode.childNode(withName: "campo", recursively: true)?.addChildNode(goalHomeNode!)
                self.sceneView.scene.rootNode.childNode(withName: "campo", recursively: true)?.addChildNode(goalAwayNode!)
                
            }
        })
        
        
    }
    
    /// Determines if the tap gesture for presenting the `VirtualObjectSelectionViewController` should be used.
    func gestureRecognizerShouldBegin(_: UIGestureRecognizer) -> Bool {
        return virtualObjectLoader.loadedObjects.isEmpty
    }
    
    func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer) -> Bool {
        return true
    }

    
    /// - Tag: restartExperience
    func restartExperience() {
        guard isRestartAvailable, !virtualObjectLoader.isLoading else { return }
        isRestartAvailable = false

        statusViewController.cancelAllScheduledMessages()

        virtualObjectLoader.removeAllVirtualObjects()
        addObjectButton.setImage(#imageLiteral(resourceName: "add"), for: [])
        addObjectButton.setImage(#imageLiteral(resourceName: "addPressed"), for: [.highlighted])

        resetTracking()

        // Disable restart for a while in order to give the session time to restart.
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.isRestartAvailable = true
        }
    }
}

