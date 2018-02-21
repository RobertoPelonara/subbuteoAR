//
//  GameManager.swift
//  ARLearning
//
//  Created by Roberto Pelonara on 14/02/2018.
//  Copyright © 2018 Antonio Sirica. All rights reserved.
//

import Foundation
import SceneKit


struct GameData: Codable {
    
    var shouldIStart:String?
    var receivedDataType:String
    var team: String?
    var position: SCNVector3?
    var force: SCNVector3?
    var nodeName: String?
    
    
    init(dataType:String,shouldIStart:String){
        receivedDataType = dataType
        self.shouldIStart = shouldIStart
    }
    init(dataType:String,team:String,FaulPosition position:SCNVector3){
        receivedDataType = dataType
        self.team = team
        self.position = position
    }
    init(dataType:String,team:String){
        receivedDataType = dataType
        self.team = team
    }
    init(dataType:String,force:SCNVector3,nodeName:String){
        receivedDataType = dataType
        self.force = force
        self.nodeName = nodeName
        
    }
    
    
}

//struct FoulData  {
//    
//    var team: String
//    var position: SCNVector3
//}
//
//struct GoalData {
//    var team: String
//}
//
//struct ShotData {
//    var force: SCNVector3
//    var nodeName: String
//}

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
    
    static var fieldSize: CGSize = CGSize(width: 1.31 , height: 2.10)
    
    //keys for dictionary
    static let foul = "foulData"
    static let start = "start"
    static let shot = "shotData"
    static let goal = "goalData"
    
    
    
    init (scene: SCNScene) {
        gameScene = scene
        
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
        
        for i in 0...10 {
            let playerScene = SCNScene(named: "Models.scnassets/Players + goal/\(id).scn")
            let playerNode = playerScene?.rootNode.childNode(withName: "player", recursively: true)
            let moltiplier: Float = (id == "home") ? 1 : -1
            
            let halfFieldSize = (width: GameManager.fieldSize.width, height: GameManager.fieldSize.height / 4)
            
            playerNode?.name = "\(id)_\(i)"
            
            let positionToApply = float3.init(x: homePlayersPosition[i].x * moltiplier * Float(halfFieldSize.width),
                                              y: homePlayersPosition[i].y * moltiplier * Float(halfFieldSize.height),
                                              z: homePlayersPosition[i].z)
            
            playerNode?.simdPosition = positionToApply
            field?.addChildNode(playerNode!)
            
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
        if abs(transform.translation.x) > Float(GameManager.fieldSize.width) ||
            abs(transform.translation.y) > Float(GameManager.fieldSize.height){
            
            let wPosition = abs(transform.translation.x) > Float(GameManager.fieldSize.width) ? Float(GameManager.fieldSize.width) : transform.translation.x
            let hPosition = abs(transform.translation.y) > Float(GameManager.fieldSize.height) ? Float(GameManager.fieldSize.height): transform.translation.y
            
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
            if abs(transform.translation.x) > Float(GameManager.fieldSize.width) ||
                abs(transform.translation.y) > Float(GameManager.fieldSize.height){
                
                let wPosition = abs(transform.translation.x) > Float(GameManager.fieldSize.width) ? Float(GameManager.fieldSize.width) : transform.translation.x
                let hPosition = abs(transform.translation.y) > Float(GameManager.fieldSize.height) ? Float(GameManager.fieldSize.height): transform.translation.y
                
                
                let vector = SCNVector3(wPosition, hPosition, 0.001)
                gameManager?.foul(committedBy: (gameManager?.currentTurn)!, atPosition: vector)
                
            }
        }
        
    }

