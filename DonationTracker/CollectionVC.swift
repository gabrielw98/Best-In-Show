//
//  CollectionVC.swift
//  DonationTracker
//
//  Created by David Gabrielyan on 15/11/18.
//  Copyright © 2018 Gabe Wilson. All rights reserved.
//

import UIKit
import Foundation

class CollectionVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    let array = ["Shoes", "Clothes", "Hats", "Households", "Electronics", "Sports", "Toys", "Books", "Others"];
    
    @IBOutlet weak var collectionLayoutOutlet: UICollectionView!
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return array.count
    }
    
    //Populate the cell with an image
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCellVC
        let imageName = array[indexPath.row] + ".png"
        cell.CellImageOutlet.image = UIImage(named: imageName)
        return cell
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let itemSize = UIScreen.main.bounds.width/4 - 10
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 40, left: 30, bottom: 10, right: 30) // redundant
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        
        layout.minimumLineSpacing = 35
        layout.minimumInteritemSpacing = 20
        
        collectionLayoutOutlet.collectionViewLayout = layout
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
