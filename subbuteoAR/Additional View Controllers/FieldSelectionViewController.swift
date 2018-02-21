//
//  FieldSelectionViewController.swift
//  subbuteoAR
//
//  Created by Roberto Pelonara on 21/02/2018.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class FieldSelectionViewCell: UICollectionViewCell{
    
    @IBOutlet weak var imageView: UIImageView!
}


class FieldSelectionViewController: UICollectionViewController {
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "fieldSelection", for: indexPath) as? FieldSelectionViewCell  else {
            fatalError("The dequeued cell is not an instance of CampaignTableViewCell.")
        }
        
        print("CELL")
        
        cell.imageView.image = GameManager.availableFields[indexPath.row]
        return cell
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        GameManager.fieldTexture = GameManager.availableFields[indexPath.row]
        navigationController?.popViewController(animated: true)
        print("We should return")
    }

    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }

}
