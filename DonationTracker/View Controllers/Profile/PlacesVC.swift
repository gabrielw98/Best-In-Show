//
//  PlacesVC.swift
//  DonationTracker
//
//  Created by Gabe Wilson on 10/26/18.
//  Copyright © 2018 Gabe Wilson. All rights reserved.
//

import Foundation
import UIKit
import GooglePlaces
import YelpAPI
import Parse

class PlacesVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var placeHeaderCollectionView: UICollectionView!
    
    var locations = [Location]()
    var images = [UIImage]()
    var placeImage = UIImage()
    var yelpClient: YLPClient?
    
    var fromMap = false
    var selectedLocationIndex = 0
    
    override func viewDidLoad() {
        createItemCollectionViews()
    }
    
    func createItemCollectionViews() {
        var index = 0
        for location in locations {
            let cell = placeHeaderCollectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: IndexPath(item: index, section: 0)) as! PlacesCollectionViewCell
            
            print("index", index)
            if let items = DataModel.itemsPerLocation[location] {
                locations[index].items = items
                cell.items = items
                cell.itemCollectionView.awakeFromNib()
                cell.itemCollectionView.reloadData()
            }
            if location == locations.last {
                print("made it to view did load", locations.count)
                placeHeaderCollectionView.delegate = self
                placeHeaderCollectionView.dataSource = self
                placeHeaderCollectionView?.isPagingEnabled = true
                if let layout = placeHeaderCollectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
                    layout.scrollDirection = .horizontal
                }
                placeHeaderCollectionView?.backgroundColor = UIColor(red: 173/255, green: 216/255, blue: 230/255, alpha: 1)
            }
            index += 1
        }
        if fromMap {
            placeHeaderCollectionView.scrollToItem(at: IndexPath(item: selectedLocationIndex, section: 0), at: .centeredHorizontally, animated: false)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return locations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var newIndex: IndexPath!
        var indexChanged = false
        if indexPath.item > 1 && indexPath.item != locations.count - 1 {
            indexChanged = true
            newIndex = IndexPath(item: indexPath.item - 1, section: 0)
        } else {
            newIndex = indexPath
        }
        let cell = placeHeaderCollectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: newIndex) as! PlacesCollectionViewCell
        if indexChanged {
            
        }
        cell.imageView.layer.cornerRadius = cell.imageView.frame.height/8
        cell.imageView.layer.masksToBounds = true
        cell.imageView.backgroundColor = self.navigationController?.navigationBar.barTintColor
        cell.imageView.layer.borderWidth = 3.0
        cell.imageView.layer.borderColor = UIColor(red: 135.0/255.0, green: 206.0/255.0, blue: 235.0/255.0, alpha: 1.0).cgColor
        cell.imageView.image = locations[newIndex.item].businessImage
        cell.imageView.contentMode = .scaleAspectFill
        cell.titleLabel.text = locations[newIndex.item].name
        cell.addressLabel.text = locations[newIndex.item].address
        print(newIndex.item, "index item")
        if !locations[newIndex.item].items.isEmpty {
            cell.itemCollectionView.isHidden = false
            cell.items = locations[newIndex.item].items
            cell.itemCollectionView.reloadData()
        } else {
            cell.itemCollectionView.isHidden = true
        }
        cell.contentView.layer.cornerRadius = 30.0
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds = true;
        cell.layer.shadowColor = UIColor.white.cgColor
        cell.layer.shadowOffset = CGSize(width:0,height: 2.0)
        cell.layer.shadowRadius = 1.0
        cell.layer.shadowOpacity = 1.0
        cell.layer.masksToBounds = false;
        cell.layer.shadowPath = UIBezierPath(roundedRect:cell.bounds, cornerRadius:cell.contentView.layer.cornerRadius).cgPath
        cell.frame.origin.y = (self.navigationController?.navigationBar.frame.maxY)!
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let navBarHeight = navigationController!.navigationBar.frame.height
        return CGSize(width: view.frame.width, height: view.frame.height - navBarHeight)
    }
}
