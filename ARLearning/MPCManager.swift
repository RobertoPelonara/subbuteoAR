import UIKit
import MultipeerConnectivity

protocol MPCManagerDelegate {
    
    func foundPeer()
    
    func lostPeer()
    
    func invitationWasReceived(fromPeer: String)
    
    func connectedWithPeer(peerID: MCPeerID)
    
    func handleReceivedData(data: [String:AnyObject])
}

class MPCManager: NSObject,MCSessionDelegate,MCNearbyServiceAdvertiserDelegate,MCBrowserViewControllerDelegate {
    
    var session: MCSession!
    var peer: MCPeerID!
    var advertiser: MCNearbyServiceAdvertiser!
    var browser : MCBrowserViewController?
    var viewController: UIViewController?
    var foundPeers = [MCPeerID]()
    var invitationHandler: ((Bool,MCSession?)-> Void)!
    var delegate: MPCManagerDelegate?
    
    override init() {
        super.init()
        
        peer = MCPeerID(displayName: UIDevice.current.name)
        
        session = MCSession(peer: peer)
        session.delegate = self
        
        let serviceBrowser = MCNearbyServiceBrowser(peer: peer, serviceType: "subbuteo-mpc")
        browser = MCBrowserViewController(browser: serviceBrowser, session: session)
        browser?.delegate = self
        
        advertiser = MCNearbyServiceAdvertiser(peer: peer, discoveryInfo: nil, serviceType: "subbuteo-mpc")
        advertiser.delegate = self
    }
    
    
    //Conformation to MCNearbyServiceAdvertiserDelegate
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        
        self.invitationHandler = invitationHandler
        
        delegate?.invitationWasReceived(fromPeer: peerID.displayName)
        
        
    }
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        
        print(error.localizedDescription)
        
    }
    
    //Conformation to MCSessionDelegate
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        
        switch state{
            
        case MCSessionState.connected:
            print("\(peerID) is now connected to the session ")
            
            delegate?.connectedWithPeer(peerID: peerID)
            
        case MCSessionState.connecting:
            print("Connecting...")
            
        case MCSessionState.notConnected:
            delegate?.lostPeer()
            
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
        let dictionary: [String:AnyObject] = ["data":data as AnyObject,"fromPeer":peerID] //in questo modo puoi risalire a chi ti ha mandato il dato. (a noi non dovrebbe servire)
        delegate?.handleReceivedData(data: dictionary)
        
        /*
         handleReceivedData deve essere una funzione di questo tipo:
         
         func handleReceivedData(data: [String : AnyObject]) {
            DispatchQueue.main.async { //il dispatchqueue ci vuole perchè deve girare in asincrono sul main thread.
         
            let receivedDataDictionary = data as Dictionary<String,AnyObject>
            let data = receivedDataDictionary["data"] as? Data
         
            if let dataDictionary = NSKeyedUnarchiver.unarchiveObject(with: data!) as? Dictionary<String,String> {
         
                if let valorechemiserve = dataDictionary["nome che chi ha inviato ha dato a questo dato"] {
                        fai la roba che dovevi fare con questo dato
                    }
         
                }
            }
         }
         */
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) { }
    
    //conform to MCBrowserViewControllerDelegate
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        
        browserViewController.dismiss(animated: true)
        
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        
        browserViewController.dismiss(animated: true)
        
    }
    
    /*funzione per inviare una stringa. Al ricevente sarà chiamata la funzione session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID). il file da inviare è un dictionary perchè il primo campo serve a distinguere il tipo di dato che  stato inviato e servirà al ricevente per accedere al dato giusto.
     Esempio: se sto inviando il tiro, il dictionary sarà : let dictionary = ["tiro","datodainviare"], mentre se mando la posizione sarà let dictionary = ["posizione", posizionedainviare]. In questo modo il ricevente userà rispettivamente dictionary["tiro"] o dictionary["posizione"].
    */
    func sendData(dictionaryWithData dictionary: Dictionary<String, String>, toPeer targetPeers: [MCPeerID]) -> Bool {
        
        let dataToSend = NSKeyedArchiver.archivedData(withRootObject: dictionary)
        let peersArray = targetPeers
        var success = true
        
        do{
            try session.send(dataToSend, toPeers: peersArray, with: .reliable)
        } catch let error as NSError {
            print(error.localizedDescription)
            success = false
        }
        
        return success
    }
    
}

