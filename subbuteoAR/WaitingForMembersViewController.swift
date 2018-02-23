//
//  WaitingForMembersViewController.swift
//  subbuteoAR
//
//  Created by Carlo Santoro on 20/02/2018.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class WaitingForMembersViewController: UIViewController,MPCManagerDelegate{
   
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
    //outlet declaration
    
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var opponentShirt: UIImageView!
    @IBOutlet weak var opponentLabel: UIOutlinedLabel!
    @IBOutlet weak var homeLabel: UIOutlinedLabel!
    
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set the delegate
        MPCManager.shared.delegate = self
        
        //title of navigation bar item
        self.navigationItem.title = "Waiting for players..."
        
        //start advertising
        MPCManager.shared.advertiser.startAdvertisingPeer()
        
        //se non sei host nasconde il pulsante wait
        startButton.isHidden = !(MPCManager.shared.isHost)
        startButton.isEnabled = false
        startButton.alpha = 0.5
        
        self.opponentLabel.isHidden = true
        self.opponentShirt.isHidden = true
        self.opponentLabel.adjustsFontSizeToFitWidth = true
        self.homeLabel.adjustsFontSizeToFitWidth = true
        if !MPCManager.shared.isHost {
            self.navigationItem.hidesBackButton = true
            self.navigationItem.title = "Connected player"
            self.opponentShirt.isHidden = false
            self.opponentLabel.isHidden = false
            self.opponentLabel.text = "You"
            self.homeLabel.text = MPCManager.shared.session.connectedPeers[0].displayName
        }
        
  
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

    //conform to UITableViewDataSource
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return MPCManager.shared.session.connectedPeers.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "waitingID")!
//
//        cell.textLabel?.text = MPCManager.shared.session.connectedPeers[indexPath.row].displayName
//        return cell
//    }
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
    
    //conform to MPCManagerDelegate
    func foundPeer() {}
    
    func lostPeer() {
        DispatchQueue.main.async {
            
            if MPCManager.shared.session.connectedPeers.count == 0 {
                self.navigationItem.title = "Waiting for players..."
                self.startButton.isEnabled = false
                self.startButton.alpha = 0.5
                self.opponentShirt.isHidden = true
                self.opponentLabel.isHidden = true
                MPCManager.shared.advertiser.startAdvertisingPeer()
            }
        }
    }
    
    func handleReceivedData(data: [String : AnyObject]) {
        DispatchQueue.main.async { //il dispatchqueue ci vuole perchè deve girare in asincrono sul main thread.
            
            let receivedDataDictionary = data as Dictionary<String,AnyObject>
            let data = receivedDataDictionary["data"] as? Data

            if let dataDictionary = NSKeyedUnarchiver.unarchiveObject(with: data!) as? Dictionary<String,String> {

                if let stringa = dataDictionary["start"] {
                    if stringa == "yes"{
                        self.performSegue(withIdentifier: "waitToAR", sender: self)
                    }
                }

            }
        }
    }
    
    func invitationWasReceived(fromPeer: String) {
        DispatchQueue.main.async {
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
        
    }
    
    func connectedWithPeer(peerID: MCPeerID) {
        DispatchQueue.main.async {
            
            if MPCManager.shared.session.connectedPeers.count == 1{
                self.navigationItem.title = "Connected player"
                self.startButton.isEnabled = true
                self.startButton.alpha = 1.0
                self.opponentShirt.isHidden = false
                self.opponentLabel.isHidden = false
                self.opponentLabel.text = MPCManager.shared.session.connectedPeers[0].displayName
                MPCManager.shared.advertiser.stopAdvertisingPeer()
            }
            
        }
    }
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

    
    @IBAction func startAction(_ sender: UIButton) {
        let dictionary = ["start":"yes"]
        MPCManager.shared.sendData(dictionaryWithData: dictionary, toPeer: MPCManager.shared.session.connectedPeers)
        self.performSegue(withIdentifier: "waitToAR", sender: self)
    }
    
    
}
