//
//  GameManager.swift
//  ARLearning
//
//  Created by Roberto Pelonara on 14/02/2018.
//  Copyright © 2018 Antonio Sirica. All rights reserved.
//

import Foundation
import SceneKit

struct FoulData: Codable {
    
    var team: String
    var position: SCNVector3
 }

struct goalData: Codable {
    var team: String
}

struct shotData: Codable {
    var force: SCNVector3
    var nodeName: String
}

enum Turn {
    case home
    case away
}

enum BitMask: Int {
    case player = 0001
    case field = 0010
}


class GameManager {
    
    static let shared = GameManager()
    
    var teams: [Turn: Team]
    
    var currentTurn: Turn = .home
    
    var scoreHome: Int = 0
    var scoreAway: Int = 0
    
    var maxScore: Int = 3
    var deltaTime: Double?
    
    private var previousTimeInterval: TimeInterval
    private var currentTimeInterval: TimeInterval
    
    static let scene: SCNScene = SCNScene(named: "Models.scnassets/campo.scn")!
    
    
    
    init () {
        let teamHome = Team(id: "home")
        let teamAway = Team(id: "away")
        teams = [.home: teamHome, .away: teamAway]
        previousTimeInterval = Date().timeIntervalSince1970
        currentTimeInterval = Date().timeIntervalSince1970
    }
    
/**
     Need to call this every frame
    */
    func tick () {
        
        currentTimeInterval = Date().timeIntervalSince1970
        
        deltaTime = currentTimeInterval - previousTimeInterval
        
        
        
    }
    
    
    func goal (scoredBy: Turn){
        switch scoredBy {
        case .home:
            scoreHome += 1
            break
        case .away:
           scoreAway += 1
            break
        }
    }
    
    
    
    func foul (committedBy: Turn, atPosition: SCNVector3){
        switch committedBy {
        case .home:
//            Il giocatore Away batte il calcio di punizione alla posizione "atPosition"
            break
        case .away:
//          Il giocatore Away batte il calcio di punizione alla posizione "atPosition"
            break
        }
    }
}

class Team {
    var players: [Player] = []
    var id: String
    
     init (id: String){
        self.id = id
        let scene = GameManager.scene
        for i in 1...10 {
            print(i)
            let playerNode = scene.rootNode.childNode(withName: "\(id)_\(i)", recursively: true)
            playerNode?.categoryBitMask = BitMask.player.rawValue
            guard let playerN = playerNode else {continue}

            let playerToAdd = Player (node: playerN)
            players.append(playerToAdd)
            
        }
    }
    
}

class Player {
    var node: SCNNode
    init(node: SCNNode) {
        self.node = node
    }
}
