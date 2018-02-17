//
//  ViewController+PlayerMovements.swift
//  ARKitInteraction
//
//  Created by Roberto Pelonara on 16/02/2018.
//  Copyright © 2018 Apple. All rights reserved.
//
import ARKit

extension ViewController {
    
      override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let result = sceneView.hitTest((touches.first?.location(in: sceneView))!, options: [.searchMode : SCNHitTestSearchMode.closest.rawValue, SCNHitTestOption.boundingBoxOnly: true, SCNHitTestOption.categoryBitMask : 1]).first
        if result == nil {
            return
        }
        if result?.node.name != "campo" {currentObject = result?.node.parent} else {return}
        print(currentObject?.name)
        touchStartPosition = result?.worldCoordinates
        touchStartTime = Date().timeIntervalSince1970
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
       
        let result = sceneView.hitTest((touches.first?.location(in: sceneView))!, options: [.searchMode : SCNHitTestSearchMode.all.rawValue, SCNHitTestOption.boundingBoxOnly: true]).first
        touchEndPosition = result?.worldCoordinates
        touchEndTime = Date().timeIntervalSince1970
        performLaunch()
    }

   
    
    
    
   func performLaunch () {
        print("PERFORM LAUNCH")
        
        guard let endingPosition = touchEndPosition else {
            print("END NOT FOUND")
            return}
        
        guard let startingPosition = touchStartPosition else {
            print("START NOT FOUND")

            return}
        
       
        var direction = endingPosition - startingPosition
        direction.normalize()
        
        print("Direction: \(direction)")
        
        print("Ending: \(endingPosition)")
        let timeDifference = touchEndTime! - touchStartTime!
        
        
        //        Calcolo del coefficiente per la forza del lancio
        
        let velocity = (Float(min(max(1 - timeDifference, 0.1), 1.0))) * self.velocityToApply
        direction.y = 0
        print("Velocity: \(velocity)")

        let impulseVector = direction * velocity
        
        currentObject?.physicsBody?.applyForce(impulseVector, asImpulse: true)
        
        
    }
    
}

