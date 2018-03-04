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
        guard let manager = (UIApplication.shared.delegate as! AppDelegate).gameManager else {print("...no game manager!"); return}
        
        let nodes: [SCNNode] = [contact.nodeA, contact.nodeB]
        for node in nodes {
            if node.name == "ball" {bNode = node}
            else if node.name == "homeGoal" || node.name == "awayGoal" {gNode = node}
        }
        guard bNode != nil else {print("no ball found!"); makeNodesNil(); return}
        guard let goalNode = gNode else {print("no goal found!"); makeNodesNil(); return}
        
        print("COLLISION FOUND!")
        
        switch goalNode.name {
        case "homeGoal":
            manager.goal(scoredBy: .away)
            print("goooal away!")
        default:
            manager.goal(scoredBy: .home)
            print("goooal home!")
        }
        
        manager.teams![.home]?.resetTransforms()
        manager.teams![.away]?.resetTransforms()
        
    }
    
    func makeNodesNil() {
        bNode = nil
        gNode = nil
    }
    
}
