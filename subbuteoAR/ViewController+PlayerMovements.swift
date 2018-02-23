//
//  ViewController+PlayerMovements.swift
//  ARKitInteraction
//
//  Created by Roberto Pelonara on 16/02/2018.
//  Copyright © 2018 Apple. All rights reserved.
//

import ARKit
import MultipeerConnectivity

extension ViewController {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let result = sceneView.hitTest((touches.first?.location(in: sceneView))!, options: [.searchMode : SCNHitTestSearchMode.closest.rawValue, SCNHitTestOption.boundingBoxOnly: true, SCNHitTestOption.categoryBitMask : 1], node: nil).first
        
        touchStartPositionScreen = touches.first?.location(in: self.view)
        
        if result == nil {
            return
        }
        if result?.node.name != "campo" {
            currentObject = result?.node.parent
            
        } else {return}
        // print(currentObject?.name)
        touchStartPosition = result?.worldCoordinates
        touchStartTime = Date().timeIntervalSince1970
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let result = sceneView.hitTest((touches.first?.location(in: sceneView))!, options: [.searchMode : SCNHitTestSearchMode.all.rawValue, SCNHitTestOption.boundingBoxOnly: true]).first
        
        touchEndPositionScreen = touches.first?.location(in: self.view)
        
        touchEndPosition = result?.worldCoordinates
        touchEndTime = Date().timeIntervalSince1970
        performLaunch()
    }
    
    
    func performLaunch () {
        // print("PERFORM LAUNCH")
        
        guard let currentPlayer = currentObject else {
            // print("Player not found fra")
            return
        }
        
        guard let endingPosition = touchEndPosition else {
            // print("END NOT FOUND")
            return}
        
        guard let startingPosition = touchStartPosition else {
            // print("START NOT FOUND")
            
            return}
        
        
        var direction = endingPosition - startingPosition
        direction.normalize()
        
        // print("Direction: \(direction)")
        
        // print("Ending: \(endingPosition)")
        let timeDifference = touchEndTime! - touchStartTime!
        
        
        //        Calcolo del coefficiente per la forza del lancio
        
        let velocity = (Float(min(max(1 - timeDifference, 0.1), 1.0))) * self.velocityToApply
        direction.y = 0
        
        let distanceValue = distance(pointA: touchStartPositionScreen!, pointB: touchEndPositionScreen!)
        
        print("DistanceValue:\(distanceValue)")
        
        let module = distanceValue.map(from: 0.0...700, to: 1.0...3.0)
        
        if module > 1.1 {
            print("Modulo: \(module)")
        let impulseVector = direction * velocity * module
        
//        let shotToSend = ShotData(force: impulseVector, nodeName: (currentObject?.name)!)
        let shotToSend = GameData(dataType: GameManager.shotKey, force: impulseVector, nodeName: (currentObject?.name)!)

        var position = currentPlayer.position
        // print("before the force the position of \(currentPlayer.name) was \(position)")
        currentPlayer.physicsBody?.type = .dynamic
        currentPlayer.physicsBody?.isAffectedByGravity = true
        
        currentPlayer.physicsBody?.applyForce(impulseVector, asImpulse: true)
        
        let _ = MPCManager.shared.sendData(gameDataToSend: shotToSend, toPeers: MPCManager.shared.session.connectedPeers)
        // print("I sent the force: \(shotToSend.force)")
       
        }
    }
    
}

