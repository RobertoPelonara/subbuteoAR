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


//TODO: creare classe per il campo per lo storing delle proprietà del campo

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
    
    var fieldSize: CGSize?
    
    
    
    
    
    init (scene: SCNScene) {
        gameScene = scene
        
        if let boundingBox = scene.rootNode.childNode(withName: "campo", recursively: true)?.boundingBox {
            
            let fieldH = CGFloat((boundingBox.max.y - boundingBox.min.y) * 0.01)
            let fieldW = CGFloat((boundingBox.min.x - boundingBox.min.x) * 0.86)
            fieldSize = CGSize(width: fieldW, height: fieldH)
            print("Bounding BOX FOUND")
        }
        
        let teamAway = Team( "away", scene)
        let teamHome = Team( "home", scene)
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
        
        for team in teams!.values {
            team.tick()
        }
        
        
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
    private var gameManager = (UIApplication.shared.delegate as! AppDelegate).gameManager
    
    
    
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
        guard let box = field?.boundingBox else {print("try again: \(id)"); return}
        let fieldWidth = box.max.x - box.min.x
        let fieldHeight = box.max.y - box.min.y
        
        for i in 0...10 {
            let playerScene = SCNScene(named: "Models.scnassets/Players + goal/\(id).scn")
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
            
            guard let playerN = playerNode else {continue}
            
            let playerToAdd = Player (node: playerN, team: self)
            players.append(playerToAdd)
            
        }
    }
    
    func tick() {
        for player in players {
            player.tick()
        }
    }
    
}

class Player {
    var node: SCNNode
    var transform: simd_float4x4
    var team: Team
    
    private var gameManager: GameManager?
    
    private var position: SCNVector3 {
        get {
            return SCNVector3(transform.translation)
        }
    }
    init(node: SCNNode, team: Team) {
        
        self.node = node
        transform = node.simdTransform
        self.team = team
        gameManager = (UIApplication.shared.delegate as! AppDelegate).gameManager
    }
    
    func tick () {
        if gameManager == nil {
        gameManager = (UIApplication.shared.delegate as! AppDelegate).gameManager
        }
        if abs(transform.translation.x) > Float((gameManager?.fieldSize?.width)!) ||
            abs(transform.translation.y) > Float((gameManager?.fieldSize?.height)!){
            
            let wPosition = abs(transform.translation.x) > Float((gameManager?.fieldSize?.width)!) ? Float((gameManager?.fieldSize?.width)!) : transform.translation.x
            let hPosition = abs(transform.translation.y) > Float((gameManager?.fieldSize?.height)!) ? Float((gameManager?.fieldSize?.height)!) : transform.translation.y
            
            let vector = SCNVector3(wPosition, hPosition, 0.001)
            transform.translation = float3(vector)
        }
    }
}
    
    class Ball {
        
        var node: SCNNode
        let transform: simd_float4x4
        private var gameManager = (UIApplication.shared.delegate as! AppDelegate).gameManager
        
        
        
        init(node: SCNNode) {
            self.node = node
            transform = node.simdTransform
        }
        
        func tick () {
            //        Check if position of the ball is off of the ground
            //        TODO: Clean this mess
            if abs(transform.translation.x) > Float((gameManager?.fieldSize?.width)!) ||
                abs(transform.translation.y) > Float((gameManager?.fieldSize?.height)!){
                
                let wPosition = abs(transform.translation.x) > Float((gameManager?.fieldSize?.width)!) ? Float((gameManager?.fieldSize?.width)!) : transform.translation.x
                let hPosition = abs(transform.translation.y) > Float((gameManager?.fieldSize?.height)!) ? Float((gameManager?.fieldSize?.height)!) : transform.translation.y
                
                let vector = SCNVector3(wPosition, hPosition, 0.001)
                gameManager?.foul(committedBy: (gameManager?.currentTurn)!, atPosition: vector)
                
            }
        }
        
    }

