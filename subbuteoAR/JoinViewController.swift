//
//  JoinViewController.swift
//  subbuteoAR
//
//  Created by Carlo Santoro on 20/02/2018.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class JoinCell: UITableViewCell{
    
    @IBOutlet weak var maglia: UIImageView!
    @IBOutlet weak var label: UIOutlinedLabel!
}

class JoinViewController: UIViewController,MPCManagerDelegate,UITableViewDataSource,UITableViewDelegate{
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

   @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var youLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set delegates
        tableView.delegate = self
        tableView.dataSource = self
        MPCManager.shared.delegate = self
        
        //Name of navigation item
        self.navigationItem.title = "Select your opponent."
        
        //start advertising for peer
        MPCManager.shared.browser.startBrowsingForPeers()
        
        //rimuove le celle bianche da sotto
        tableView.tableFooterView = UIView()
        let color = UIColor(patternImage: #imageLiteral(resourceName: "gradiente"))
        youLabel.textColor = color
        tableView.rowHeight = 168
        self.tableView.separatorStyle = .none
        
        
        
        
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

        let cell = tableView.dequeueReusableCell(withIdentifier: "joinID") as! JoinCell
        cell.label.text = MPCManager.shared.foundPeers[indexPath.row].displayName
        cell.label.adjustsFontSizeToFitWidth = true
        
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

class UIOutlinedLabel: UILabel {
    
    var outlineWidth: CGFloat = 1
    var outlineColor: UIColor = UIColor.white
    
    override func drawText(in rect: CGRect) {
        
        let strokeTextAttributes: [NSAttributedStringKey : Any] = [
            NSAttributedStringKey.strokeColor : UIColor.white,
            NSAttributedStringKey.foregroundColor : UIColor(patternImage: #imageLiteral(resourceName: "gradiente")),
            NSAttributedStringKey.strokeWidth : -2.0,
            ]
        
        self.attributedText = NSAttributedString(string: self.text ?? "", attributes: strokeTextAttributes)
        super.drawText(in: rect)
    }
}
