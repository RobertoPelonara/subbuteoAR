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
        DispatchQueue.main.async { 
        let receivedData = data["data"] as? Data
            
            do{
                let shotData = try JSONDecoder().decode(ShotData.self, from: receivedData!)
                let player = self.sceneView.scene.rootNode.childNode(withName: shotData.nodeName, recursively: true)
                player?.physicsBody?.applyForce(shotData.force, asImpulse: true)
            }
            catch{
                
            }
            
                
            }
        }
        
    }

