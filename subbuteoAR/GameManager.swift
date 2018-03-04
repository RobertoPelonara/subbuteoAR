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

class GameManager {
    
    static let foulKey = "foul"
    static let goalKey = "goal"
    static let shotKey = "shot"
    static let startKey = "start"
    var teams: [Turn: Team]?
    var ball: Ball?
    var currentTurn: Turn = .home
    
    var scoreHome: Int = 0
    var scoreAway: Int = 0
    
    var maxScore: Int = 3
    var deltaTime: Double?
    
    static var fieldTexture = #imageLiteral(resourceName: "field1.png")
    
    static var availableFields = [#imageLiteral(resourceName: "field1.png"),
                                  #imageLiteral(resourceName: "field2.png"),
                                  #imageLiteral(resourceName: "field3.png"),
                                  #imageLiteral(resourceName: "field4.png"),
                                  #imageLiteral(resourceName: "field5.png"),
                                  #imageLiteral(resourceName: "field6.png"),
                                  #imageLiteral(resourceName: "field7.png")]
    
    
    static var scoreGoal = [ #imageLiteral(resourceName: "score_0"), #imageLiteral(resourceName: "score_1"), #imageLiteral(resourceName: "score_2"), #imageLiteral(resourceName: "score_3")]
    
    private var previousTimeInterval: TimeInterval
    private var currentTimeInterval: TimeInterval
    var gameScene: SCNScene?
    
    static var fieldSize: CGSize = CGSize(width: 1.31 , height: 2.10)
    
    init (scene: SCNScene) {
        gameScene = scene
        
        let teamAway = Team( "away", scene, .away)
        let teamHome = Team( "home", scene, .home)
        teams = [.home: teamHome, .away: teamAway]
        let ballScene = SCNScene(named: "Models.scnassets/Players + goal/ball.scn")
        let ballNode = ballScene?.rootNode.childNode(withName: "ball", recursively: true)
        ballNode?.simdPosition = float3(0.0, 0.0, 0.1)
        scene.rootNode.childNode(withName: "field", recursively: true)?.addChildNode(ballNode!)
        self.teams![.home]?.placeTeamPlayers(scene)
        self.teams![.away]?.placeTeamPlayers(scene)
        
        ball = Ball(node: scene.rootNode.childNode(withName: "ball", recursively: true)!)
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
        ball?.tick()
        
        
    }
    
    

    func goal (scoredBy: Turn){
        
        let window = UIApplication.shared.keyWindow
        let vc = window?.rootViewController
        var viewController: ViewController?
        if (vc?.presentedViewController != nil){
            viewController = vc?.presentedViewController as? ViewController;
        }
        
        switch scoredBy {
        case .home:
            scoreHome += 1
//            Animation
            
            if viewController == nil{
                print("viewController è null")
            }
            
            viewController?.goal(image: GameManager.scoreGoal[scoreHome], turn: .home)
            
            if scoreHome > 3 {
//                Home Wins
                
            }
            break
        case .away:
            scoreAway += 1
//            Animation
            viewController?.goal(image: GameManager.scoreGoal[scoreHome], turn: .away)
            
            if scoreAway > 3 {
//                Away wins
                
            }
            break
        }
        
    }
    
    
    
    func foul (committedBy: Turn, atPosition: SCNVector3){
//        switch committedBy {
//        case .home:
//            print("Home Foul")
//            gameScene?.physicsWorld.speed = 0
//           ball?.node.simdPosition = float3(atPosition)
//           
//            break
//        case .away:
//            print("Away Foul")
//            gameScene?.physicsWorld.speed = 0
//            ball?.node.simdPosition = float3(atPosition)
//            break
//        }
    }
}

class Team {
    var players: [Player] = []
    var id: String
    var turn: Turn
    var gameManager = (UIApplication.shared.delegate as! AppDelegate).gameManager
    
    var homePlayersPosition: [float3] = [float3(0.7, 0, 0.1),
                                         float3(0.5, 0.9, 0.1),
                                         float3(0.5, 0.6, 0.1),
                                         float3(0.5, 0.3, 0.1),
                                         float3(0.5, 0, 0.1),
                                         float3(0.5, -0.3, 0.1),
                                         float3(0.5, -0.6, 0.1),
                                         float3(0.5, -0.9, 0.1),
                                         float3(0.1, 0, 0.1),
                                         float3(0.1, 0.6, 0.1),
                                         float3(0.1, -0.6, 0.1)]
    
    init (_ id: String,_ scene: SCNScene, _ turn: Turn){
        self.id = id
        self.turn = turn
    }
    
    func resetPositions(_ scene: SCNScene) {
        guard let field = scene.rootNode.childNode(withName: "campo", recursively: true) else  {print("failed position reset - no campo"); return}
        guard let ball = scene.rootNode.childNode(withName: "ball", recursively: true) else  {print("failed position reset - no ball"); return}
    
        for node in field.childNodes {
            if (node.name?.hasPrefix("\(id)_"))! {node.removeFromParentNode()}
        }
        
        ball.removeFromParentNode()
        
        placeTeamPlayers(scene)
    }
    
    func placeTeamPlayers(_ scene: SCNScene) {
        guard let field = scene.rootNode.childNode(withName: "campo", recursively: true) else  {print("failed position reset - no campo"); return}
        
        for i in 0...10 {
            let playerScene = SCNScene(named: "Models.scnassets/Players + goal/\(id).scn")
            let playerNode = playerScene?.rootNode.childNode(withName: "player", recursively: true)
            let moltiplier: Float = (id == "home") ? 1 : -1
            
            let halfFieldSize = (width: GameManager.fieldSize.width, height: GameManager.fieldSize.height / 4)
            
            playerNode?.name = "\(id)_\(i)"
            
            let positionToApply = float3.init(x: homePlayersPosition[i].x * moltiplier * Float(halfFieldSize.width),
                                              y: homePlayersPosition[i].y * moltiplier * Float(halfFieldSize.height),
                                              z: homePlayersPosition[i].z)
            
            playerNode?.simdWorldPosition = positionToApply
            
            field.addChildNode(playerNode!)
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
        
//        if gameManager == nil {
//            gameManager = (UIApplication.shared.delegate as! AppDelegate).gameManager
//        }
//
//        let collisionTest = gameManager?.gameScene?.physicsWorld.contactTest(with: node.physicsBody!, options: [SCNPhysicsWorld.TestOption.backfaceCulling : false]).first
//        if let collision = collisionTest?.nodeB {
//            if gameManager?.currentTurn != team.turn {
//                if collision == gameManager?.ball?.node {
//                    node.simdPosition = node.simdPosition - (collision.simdPosition - node.simdPosition)
//                    gameManager?.foul(committedBy: team.turn,
//                                      atPosition: collision.position)
//                }
//            }
//        }
        
    }
}
    
    class Ball {
        
        var node: SCNNode
        let transform: simd_float4x4
        private var gameManager = (UIApplication.shared.delegate as! AppDelegate).gameManager
       
        init(node: SCNNode) {
            self.node = node
          node.physicsBody?.type = .dynamic
            transform = node.simdTransform
            
        }
        
        func tick () {
            //        Check if position of the ball is off of the ground
            //        TODO: Clean this mess
           
            let result = gameManager?.gameScene?.physicsWorld.contactTest(with: node.physicsBody!, options: nil).first
            if let printValue = result?.nodeB.name {
                print(printValue)
                print("ENTRA IN TICK")
            }
            if let collision = result?.nodeB {
                if collision.parent?.name == "goal"{
                    gameManager?.goal(scoredBy: .home)
                    print("entra in goal_away")
        
                }
                else if collision.parent?.name == "goald"{
                    gameManager?.goal(scoredBy: .away)
                    print("entra in goal_away")
                }
            }
            
        }
        
    }

