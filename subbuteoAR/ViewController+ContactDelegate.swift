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
        let nodes: [SCNNode] = [contact.nodeA, contact.nodeB]
        var bNode: SCNNode?
        var gNode: SCNNode?
        for node in nodes {
            if node.name == "ball" {bNode = node}
            else if node.name == "homeGoal" || node.name == "awayGoal" {gNode = node}
        }
        guard let manager = (UIApplication.shared.delegate as! AppDelegate).gameManager else {print("...no game manager!"); return}
        guard let ballNode = bNode else {print("no ball found!"); return}
        guard let goalNode = gNode else {print("no goal found!"); return}
        print("COLLISION FOUND!")
        
        switch goalNode.name {
        case "homeGoal":
            manager.goal(scoredBy: .away)
            print("goooal away!")
        default:
            manager.goal(scoredBy: .home)
            print("goooal home!")
        }
    }
}
