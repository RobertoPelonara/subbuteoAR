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

struct GoalData: Codable {
    var team: String
}

struct ShotData: Codable {
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
    
    
    var teams: [Turn: Team]?
    
    var currentTurn: Turn = .home
    
    var scoreHome: Int = 0
    var scoreAway: Int = 0
    
    var maxScore: Int = 3
    var deltaTime: Double?
    
    private var previousTimeInterval: TimeInterval
    private var currentTimeInterval: TimeInterval
    var gameScene: SCNScene?
    
    
    
    
    init (scene: SCNScene) {
        gameScene = scene
        let teamHome = Team( "home", scene)
        let teamAway = Team( "away", scene)
        teams = [.home: teamHome, .away: teamAway]
        previousTimeInterval = Date().timeIntervalSince1970
        currentTimeInterval = Date().timeIntervalSince1970
    }
    
    init() {
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
    
    
    var homePlayersPosition: [float3] = [float3(0.8, 0, 0),
                                         float3(0.5, 0.9, 0),
                                         float3(0.5, 0.6, 0),
                                         float3(0.5, 0.3, 0),
                                         float3(0.5, 0, 0),
                                         float3(0.5, -0.3, 0),
                                         float3(0.5, -0.6, 0),
                                         float3(0.5, -0.9, 0),
                                         float3(0.1, 0, 0),
                                         float3(0.1, 0.6, 0),
                                         float3(0.1, -0.6, 0)]
    
    init (_ id: String,_ scene: SCNScene){
        self.id = id
        let field = scene.rootNode.childNode(withName: "campo", recursively: true)

        let fieldHeight = (field?.boundingBox.max.y)! - (field?.boundingBox.min.y)!
        let fieldWidth = (field?.boundingBox.max.x)! - (field?.boundingBox.min.x)!

        
        for i in 0...10 {
            let playerScene = SCNScene(named: "Models.scnassets/Players/\(id).scn")
            let playerNode = playerScene?.rootNode.childNode(withName: "player", recursively: true)
            let moltiplier: Float = (id == "home") ? 1 : -1
          
            let halfFieldSize = CGSize(width: CGFloat((fieldWidth / 2) * 0.9),
                                       height: CGFloat(((fieldHeight / 2) * 0.75) / 1.75))
            
            playerNode?.name = "\(id)_\(i)"
            
            let positionToApply = float3.init(x: homePlayersPosition[i].x * moltiplier * Float(halfFieldSize.width),
                                              y: homePlayersPosition[i].y * moltiplier * Float(halfFieldSize.height),
                                              z: homePlayersPosition[i].z)
            
            playerNode?.simdPosition = positionToApply
            scene.rootNode.childNode(withName: "campo", recursively: true)?.addChildNode(playerNode!)
            
            
            print(scene.rootNode.childNode(withName: "campo", recursively: true)?.childNodes)

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
