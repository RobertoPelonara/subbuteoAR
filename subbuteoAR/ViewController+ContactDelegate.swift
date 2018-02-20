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
        
        for team in ((UIApplication.shared.delegate as! AppDelegate).gameManager!.teams?.values)! {
            for player in team.players {
                if player.node == contact.nodeA || player.node == contact.nodeB {
                    print("CONTACT")
                }
            }
        }
        
    }
}
