import UIKit
import MultipeerConnectivity

protocol MPCManagerDelegate {
    
    func foundPeer()//chiamata se un nuovo peer si connette
    
    func lostPeer()//chiamata se un peer si è disconnesso
    
    func invitationWasReceived(fromPeer: String)// chiamata quando ricevi un invito, deve mostrare il pop up per accettare ecc
    
    func connectedWithPeer(peerID: MCPeerID)//chiamata quando un nuovo peer si connette con te
    
    func handleReceivedData(data: [String:AnyObject]) //chiamata quando ricevi un dato
}

class MPCManager: NSObject,MCSessionDelegate,MCNearbyServiceAdvertiserDelegate,MCBrowserViewControllerDelegate {
    
    static let shared = MPCManager()
    var isHost = false
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
        
        
        /*
         Solitamente ci va questa funzione qua
         
         func invitationWasReceived(fromPeer: String) {
         
         let alert = UIAlertController(title: "", message: "\(fromPeer) wants to play with you.", preferredStyle: UIAlertControllerStyle.alert)
         alert.view.tintColor = UIColor.init(red: 153/255, green: 39/255, blue: 199/255, alpha: 1)
         
         let acceptAction: UIAlertAction = UIAlertAction(title: "Accept", style: UIAlertActionStyle.default) { (alertAction) -> Void in
         self.appDelegate.mpcManager.invitationHandler(true, self.appDelegate.mpcManager.session)
         }
         
         let declineAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (alertAction) -> Void in
         self.appDelegate.mpcManager.invitationHandler(false,nil)
         }
         
         alert.addAction(acceptAction)
         alert.addAction(declineAction)
         
         OperationQueue.main.addOperation { () -> Void in
         self.present(alert, animated: true, completion: nil)
         }
         
         }
         */
        
        
        
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
         fai la roba che dovevi fare con valorechemiserve
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
    
    func sendData(codableToSend codable: Codable, toPeers targets: [MCPeerID]) -> Bool{
        
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(codable as? Any)
            let jsonString = String(data: jsonData, encoding: .utf8)
            print("JSON String : " + jsonString!)
        }
        catch {
        }
        
    }
    
    func sendData(dictionaryWithData dictionary: Dictionary<String, Float>, toPeer targetPeers: [MCPeerID]) -> Bool {
        
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

