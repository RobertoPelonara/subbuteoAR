//
//  JoinViewController.swift
//  subbuteoAR
//
//  Created by Carlo Santoro on 20/02/2018.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class JoinViewController: UIViewController,MPCManagerDelegate,UITableViewDataSource,UITableViewDelegate{
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

   @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set delegates
        tableView.delegate = self
        tableView.dataSource = self
        MPCManager.shared.delegate = self
        
        //Name of navigation item
        self.navigationItem.title = "Select a player."
        
        //start advertising for peer
        MPCManager.shared.browser.startBrowsingForPeers()
        
        //rimuove le celle bianche da sotto
        tableView.tableFooterView = UIView()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

    //Conformation to UITableViewDataSource and UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return MPCManager.shared.foundPeers.count
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "joinID")!
        cell.textLabel?.text = MPCManager.shared.foundPeers[indexPath.row].displayName
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            let selectedPeer = MPCManager.shared.foundPeers[indexPath.row] as MCPeerID
            
            MPCManager.shared.browser.invitePeer(selectedPeer, to: MPCManager.shared.session, withContext: nil, timeout: 20)
        }
    }
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

    //conformation to MPCMANAGER DELEGATE
    func invitationWasReceived(fromPeer: String) {}
    
    func connectedWithPeer(peerID: MCPeerID) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "joinToWaitID", sender: self)
        }
        
    }
    
    func handleReceivedData(data: [String : AnyObject]) {}
    
    func foundPeer() {
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }
    
    func lostPeer() {
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }
    
    

}
