//
//  ViewControllerARSessionDelegate.swift
//  ARLearning
//
//  Created by Antonio Sirica on 08/02/2018.
//  Copyright © 2018 Antonio Sirica. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

extension ViewController: ARSessionDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        if detectPlane {
            
            guard let anchor = anchor as? ARPlaneAnchor else {return}
            
            let width = CGFloat(anchor.extent.x)
            let height = CGFloat(anchor.extent.z)
            let plane = SCNPlane(width: width, height: height)
            
            plane.materials.first?.diffuse.contents = UIColor.black.withAlphaComponent(0.5)
            
            let planeNode = SCNNode(geometry: plane)
            
            let x = CGFloat(anchor.center.x)
            let y = CGFloat(anchor.center.y)
            let z = CGFloat(anchor.center.z)
            
            let planePhysicsShape = SCNPhysicsShape(geometry: plane, options: nil)
            
            //planeNode.physicsBody = SCNPhysicsBody(type: .static, shape: planePhysicsShape)
            
            planeNode.position = SCNVector3(x, y, z)
            planeNode.eulerAngles.x = -.pi / 2
            
            node.addChildNode(planeNode)
            planeNode.name = "plane"
        }
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        if detectPlane {
            
            guard let anchor = anchor as? ARPlaneAnchor,
                let planeNode = node.childNodes.first,
                let plane = planeNode.geometry as? SCNPlane
                else {return}
            
            let width = CGFloat(anchor.extent.x)
            let height = CGFloat(anchor.extent.z)
            plane.width = width
            plane.height = height
            
            let x = CGFloat(anchor.center.x)
            let y = CGFloat(anchor.center.y)
            let z = CGFloat(anchor.center.z)
            
            let planePhysicsShape = SCNPhysicsShape(geometry: plane, options: nil)
            
//            planeNode.physicsBody = SCNPhysicsBody(type: .static, shape: planePhysicsShape)
            
            planeNode.position = SCNVector3(x, y, z)
            planeNode.eulerAngles.x = -.pi / 2
            
        }
        
    }
    
}
