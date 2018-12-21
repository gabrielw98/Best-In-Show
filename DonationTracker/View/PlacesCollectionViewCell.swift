//
//  PlacesCollectionViewItem.swift
//  DonationTracker
//
//  Created by Gabe Wilson on 10/29/18.
//  Copyright © 2018 Gabe Wilson. All rights reserved.
//

import Foundation
import UIKit

class PlacesCollectionViewCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var itemCollectionView: UICollectionView!
    
    var items = [Item]()
    var selectedItem = Item()
    
    override func layoutSubviews() {
        print("in layout subviews")
        itemCollectionView.delegate = self
        itemCollectionView.dataSource = self
        if let layout = itemCollectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.sectionInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("creating cell")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ItemCell
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.myviewTapped(_:)))
        tapGesture.name = String(describing: indexPath.item)
        cell.addGestureRecognizer(tapGesture)
        cell.priceLabel.text = items[indexPath.row].price
        cell.imageView.image = items[indexPath.row].image
        cell.priceBackground.alpha = 0.6
        return cell
    }
    
    @objc func myviewTapped(_ sender: UITapGestureRecognizer) {
        print(sender.name!)
        DataModel.placesRef.selectedItem = self.items[Int(sender.name!)!]
        DataModel.placesRef.performSegue(withIdentifier: "showDetails", sender: nil)
        print("tapped")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowayout = collectionViewLayout as? UICollectionViewFlowLayout
        let space: CGFloat = (flowayout?.minimumInteritemSpacing ?? 0.0) + (flowayout?.sectionInset.left ?? 0.0) + (flowayout?.sectionInset.right ?? 0.0)
        let size:CGFloat = (collectionView.frame.size.width - space) / 2.0
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("selected Item:", items[indexPath.item].name)
        self.selectedItem = items[indexPath.item]
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

protocol CollectionViewCellDelegate: class {
    // Declare a delegate function holding a reference to `UICollectionViewCell` instance
    func collectionViewCell(_ cell: UICollectionViewCell, buttonTapped: UIButton)
}


// Make `CollectionViewController` confrom to the delegate
extension PlacesVC: CollectionViewCellDelegate {
    func collectionViewCell(_ cell: UICollectionViewCell, buttonTapped: UIButton) {
        // You have the cell where the touch event happend, you can get the indexPath like the below
        let indexPath = self.placeHeaderCollectionView.indexPath(for: cell)
        // Call `performSegue`
        print("performing segue")
        self.performSegue(withIdentifier: "showDetails", sender: nil)
    }
    
}
