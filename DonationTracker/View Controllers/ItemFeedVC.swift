//
//  ItemFeedVC.swift
//  DonationTracker
//
//  Created by Gabe Wilson on 11/19/18.
//  Copyright © 2018 Gabe Wilson. All rights reserved.
//

import Foundation
import UIKit

class ItemFeedVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func itemFeedUnwind(segue: UIStoryboardSegue) {
        viewDidLoad()
    }
    
    var items = [Item]()
    var fromNewItem = false
    
    override func viewDidAppear(_ animated: Bool) {
        if fromNewItem {
            collectionView.reloadData()
            fromNewItem = false
        }
    }
    
    override func viewDidLoad() {
        print("here in the feed")
        items = DataModel.items
        collectionView.delegate = self
        collectionView.dataSource = self
        if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        }
        collectionView.reloadData()
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ItemCell
        cell.priceLabel.text = items[indexPath.row].price
        cell.imageView.image = items[indexPath.row].image
        cell.priceBackground.alpha = 0.6
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        print("minimum")
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowayout = collectionViewLayout as? UICollectionViewFlowLayout
        let space: CGFloat = (flowayout?.minimumInteritemSpacing ?? 0.0) + (flowayout?.sectionInset.left ?? 0.0) + (flowayout?.sectionInset.right ?? 0.0)
        let size:CGFloat = (collectionView.frame.size.width - space) / 2.0
        return CGSize(width: size, height: size)
    }
    
}
