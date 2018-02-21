import Foundation
import SceneKit
import MultipeerConnectivity

extension ViewController: MPCManagerDelegate {
    
    func foundPeer() {
        
    }
    
    func lostPeer() {
        
    }
    
    func invitationWasReceived(fromPeer: String) {
        
    }
    
    func connectedWithPeer(peerID: MCPeerID) {
        
    }
    
    func handleReceivedData(data: [String : AnyObject]) {
        print("H R D")
        DispatchQueue.main.async {
            
            let receivedData = data["data"] as? Data
            
            do{
//
//                let gameData = try JSONDecoder().decode(GameData.self, from: receivedData!)
//
//                switch gameData.receivedDataType {
//
//                case GameManager.foul:
//                    break
//
//                case GameManager.shot:
//                    let player = self.sceneView.scene.rootNode.childNode(withName: gameData.nodeName!, recursively: true)
//                    var position = player?.position
//                    print("prima del tiro la posizione è \(position)")
//                    player?.physicsBody?.applyForce(gameData.force!, asImpulse: true)
//                    position = player?.position
//                    print("I received the force \(gameData.force!) and after the force the position is ")
//                    break
//                case GameManager.goal:
//                    break
//
//                default:
//                    break
//                }
                
            }catch {
                print("there was an error")
            }
            
        }
    }
    
}

