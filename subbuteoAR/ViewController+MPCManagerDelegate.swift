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
            print("CRISTO \(receivedData)")
            
            do{
                let shotData = try JSONDecoder().decode(ShotData.self, from: receivedData!)
                print("data received \(shotData.nodeName)")
                let player = self.sceneView.scene.rootNode.childNode(withName: shotData.nodeName, recursively: true)
                player?.physicsBody?.applyForce(shotData.force, asImpulse: true)
                print("force applyed")
            }
            catch{
                
            }
            
                
            }
        }
        
    }

