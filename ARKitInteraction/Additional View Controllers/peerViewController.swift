//
//  peerViewController.swift
//  ARKitInteraction
//
//  Created by Roberto Pelonara on 16/02/2018.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import MultipeerConnectivity


class peerViewController: UIViewController, MPCManagerDelegate {
    func foundPeer() {
        
    }
    
    func lostPeer() {
        
    }
    
    func invitationWasReceived(fromPeer: String) {
        let alert = UIAlertController(title: "", message: "\(fromPeer) wants to play with you.", preferredStyle: UIAlertControllerStyle.alert)
        alert.view.tintColor = UIColor.init(red: 153/255, green: 39/255, blue: 199/255, alpha: 1)
        
        let acceptAction: UIAlertAction = UIAlertAction(title: "Accept", style: UIAlertActionStyle.default) { (alertAction) -> Void in
            MPCManager.shared.invitationHandler(true, MPCManager.shared.session)
        }
        
        let declineAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (alertAction) -> Void in
            MPCManager.shared.invitationHandler(false,nil)
        }
        
        alert.addAction(acceptAction)
        alert.addAction(declineAction)
        
        OperationQueue.main.addOperation { () -> Void in
            self.present(alert, animated: true, completion: nil)
        }

    }
    
    func connectedWithPeer(peerID: MCPeerID) {
        let segue = UIStoryboardSegue(identifier: "goToGame", source: MPCManager.shared.browser!, destination: UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "gameView"))
        performSegue(withIdentifier: "goToGame", sender: self)    }
    
    func handleReceivedData(data: [String : AnyObject]) {
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MPCManager.shared.delegate = self
    }
    
    @IBAction func hostAction(_ sender: Any) {
        MPCManager.shared.advertiser!.startAdvertisingPeer()
        MPCManager.shared.isHost = true
    }
    
    @IBAction func joinAction(_ sender: Any) {
        self.navigationController?.pushViewController((MPCManager.shared.browser!), animated: true)
        MPCManager.shared.browser?.browser?.startBrowsingForPeers()
        
        
        
    }
    
}
