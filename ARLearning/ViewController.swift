//
//  ViewController.swift
//  ARLearning
//
//  Created by Antonio Sirica on 08/02/2018.
//  Copyright © 2018 Antonio Sirica. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    var detectPlane = true
    var placeBalls = true
    var placeField = true
    
    
    var currentCubeNode: SCNNode?
    var fieldNode: SCNNode?
    let cube = SCNSphere(radius: 0.15)//SCNBox(width: 0.15, height: 0.15, length: 0.15, chamferRadius: 0)
    
    var startTouchTime: TimeInterval!
    var endTouchTime: TimeInterval!
    
    var startPosition : SCNVector3?
    var endPosition: SCNVector3?
    
    var myCubes: Set<SCNNode> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        sceneView.session.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    func throwCube() {
        
        guard let cubeNode = currentCubeNode else { return }
        guard let startingPosition = startPosition else {
            print("startingPoint not found")
            return
        }
        guard let endingPosition = endPosition else {
            print("endingPoint not found")
            return
        }
        
//        let timeDifference = endTouchTime - startTouchTime
        
        let impulseVector = SCNVector3(
            ((endPosition?.x)! - (startPosition?.x)!) * 10,
            ((endPosition?.y)! - (startPosition?.y)!) * 10,
            ((endPosition?.z)! - (startPosition?.z)!) * 10)
        
//        print("the force is \(impulseVector)")
        cubeNode.physicsBody?.applyForce(impulseVector, asImpulse: true)
        currentCubeNode = nil
        startTouchTime = nil
        endTouchTime = nil
        
    }
    
    @IBAction func switchAction(_ sender: Any) {
        detectPlane = !detectPlane
    }
    
    @IBAction func switchAction2(_ sender: Any) {
        placeBalls = !placeBalls
    }
    
    private func nodeBelongsToVirtualObject(_ node: SCNNode?) -> Bool {
        if let _ = node {
            return sceneView.scene.rootNode.childNodes.contains(node!) || nodeBelongsToVirtualObject(node!.parent)
        }
        
        return false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count > 0 {
            
            let hitTestPlane = sceneView.hitTest((touches.first?.location(in: sceneView))!, types: .existingPlaneUsingExtent)
            
            guard let result = sceneView.hitTest((touches.first?.location(in: sceneView))!, options: [.searchMode : SCNHitTestSearchMode.all.rawValue]).first else {
                return
            }
            
            if result.node.name == nil {
                result.node.isHidden = true
            }
            
            if myCubes.contains(result.node) || result.node.parent?.name == "ball" {
                currentCubeNode = result.node
                
                startPosition = result.worldCoordinates
            }

            if placeField && hitTestPlane.count > 0 {
                
                let fieldScene = SCNScene(named: "art.scnassets/campo.scn")
                fieldNode = fieldScene?.rootNode
               
                
                let x = (hitTestPlane.first?.worldTransform.position.x)!
                let y = (hitTestPlane.first?.worldTransform.position.y)!
                let z = (hitTestPlane.first?.worldTransform.position.z)!
                
                fieldNode?.position = SCNVector3(x,y,z)
                fieldNode?.name = "field"
                
                sceneView.scene.rootNode.addChildNode(fieldNode!)
                
                placeField = false
                return
            }
            
            else if placeBalls {
                
                let cubeNode = SCNNode(geometry: cube)
                
                
                result.node.addChildNode(cubeNode)

                let x = result.localCoordinates.x
                let y = result.localCoordinates.y
                let z = result.localCoordinates.z + 1
                cubeNode.position = SCNVector3(x,y,z)

                print(result.localCoordinates)
                print("Cube Position \(cubeNode.position)")
                
                cubeNode.name = "Cube"
                let cubePhysicsShape = SCNPhysicsShape(geometry: cube, options: [SCNPhysicsShape.Option.scale : 0.5])
                cubeNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: cubePhysicsShape)
                myCubes.insert(cubeNode)

            }
            
        }
        
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        guard let result = sceneView.hitTest((touches.first?.location(in: sceneView))!, options: [.searchMode : SCNHitTestSearchMode.all.rawValue]).first else {
            return
        }
        
        endPosition = result.worldCoordinates
        
        
        endTouchTime = Date().timeIntervalSince1970
        throwCube()
        
    }
    
}
