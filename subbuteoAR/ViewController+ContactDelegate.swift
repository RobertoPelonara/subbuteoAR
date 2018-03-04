//
//  ViewController+ContactDelegate.swift
//  subbuteoAR
//
//  Created by Roberto Pelonara on 20/02/2018.
//  Copyright © 2018 Apple. All rights reserved.
//
import SceneKit
import Foundation

extension ViewController: SCNPhysicsContactDelegate {
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        if gameSet == true {return}
        
        DispatchQueue.main.async {
            guard let manager = (UIApplication.shared.delegate as! AppDelegate).gameManager else {return}
            
            let nodes: [SCNNode] = [contact.nodeA, contact.nodeB]
            for node in nodes {
                if node.name == "ball" {self.bNode = node}
                else if node.name == "homeGoal" || node.name == "awayGoal" {self.gNode = node}
            }
            guard self.bNode != nil else {self.makeNodesNil(); return}
            guard let goalNode = self.gNode else {self.makeNodesNil(); return}
            
            print("COLLISION FOUND!")
            
            switch goalNode.name {
            case "homeGoal":
                self.goal(.away)
            case "awayGoal":
                self.goal(.home)
            default:
                break
            }
            
            self.resetPositions()
            manager.placeBall(manager.gameScene!)
            self.gameSet = true
            self.makeNodesNil()
        }
    }
    
    func makeNodesNil() {
        bNode = nil
        gNode = nil
    }
    
    func resetPositions() {
        guard let manager = (UIApplication.shared.delegate as! AppDelegate).gameManager else {return}
        manager.teams![.home]?.resetPositions(manager.gameScene!)
        manager.teams![.away]?.resetPositions(manager.gameScene!)
    }
    
}
