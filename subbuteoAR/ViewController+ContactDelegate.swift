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
        
        guard let manager = (UIApplication.shared.delegate as! AppDelegate).gameManager else {return}
        
        let nodes: [SCNNode] = [contact.nodeA, contact.nodeB]
        for node in nodes {
            if node.name == "ball" {bNode = node}
            else if node.name == "homeGoal" || node.name == "awayGoal" {gNode = node}
        }
        guard bNode != nil else {makeNodesNil(); return}
        guard let goalNode = gNode else {makeNodesNil(); return}
        
        print("COLLISION FOUND!")
        
        switch goalNode.name {
        case "homeGoal":
            manager.goal(scoredBy: .away)
            print("goooal away!")
        default:
            manager.goal(scoredBy: .home)
            print("goooal home!")
        }
        
        resetPositions()
        manager.placeBall(manager.gameScene!)
        gameSet = true
    }
    
    func makeNodesNil() {
        bNode = nil
        gNode = nil
    }
    
    func resetPositions() {
        guard let manager = (UIApplication.shared.delegate as! AppDelegate).gameManager else {print("...no game manager!"); return}
        manager.teams![.home]?.resetPositions(manager.gameScene!)
        manager.teams![.away]?.resetPositions(manager.gameScene!)
    }
    
}
