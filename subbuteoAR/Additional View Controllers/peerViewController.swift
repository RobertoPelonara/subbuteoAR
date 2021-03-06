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
        
    }
    
    func connectedWithPeer(peerID: MCPeerID) {
//        DispatchQueue.main.async {
//            let segue = UIStoryboardSegue(identifier: "goToGame", source: MPCManager.shared.browser!, destination: UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "gameView"))
//            self.performSegue(withIdentifier: "goToGame", sender: self)
//        }
    }
    
    func handleReceivedData(data: [String : AnyObject]) {
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MPCManager.shared.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @IBAction func joinAction(_ sender: UIButton) {
        MPCManager.shared.isHost = false
    }
    
    @IBAction func hostAction(_ sender: UIButton) {
        MPCManager.shared.isHost = true
    }
    

    
    @IBAction func ARAction(_ sender: UIButton) {
//        let segue = UIStoryboardSegue(identifier: "goToGame", source: MPCManager.shared.browser!, destination: UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "gameView"))
//        performSegue(withIdentifier: "goToGame", sender: self)
    }
    
}
