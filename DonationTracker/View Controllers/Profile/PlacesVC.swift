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
    
    override func viewDidLoad() {
        print("made it to view did load", locations.count)
        placeHeaderCollectionView.delegate = self
        placeHeaderCollectionView.dataSource = self
        placeHeaderCollectionView?.isPagingEnabled = true
        if let layout = placeHeaderCollectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
        placeHeaderCollectionView?.backgroundColor = UIColor(red: 173/255, green: 216/255, blue: 230/255, alpha: 1)
        placeHeaderCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return locations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print(indexPath.row, "index row")
        let cell = placeHeaderCollectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! PlacesCollectionViewCell
        cell.imageView.layer.cornerRadius = cell.imageView.frame.height/8
        cell.imageView.layer.masksToBounds = true
        cell.imageView.backgroundColor = self.navigationController?.navigationBar.barTintColor
        cell.imageView.layer.borderWidth = 3.0
        cell.imageView.layer.borderColor = UIColor(red: 135.0/255.0, green: 206.0/255.0, blue: 235.0/255.0, alpha: 1.0).cgColor
        cell.imageView.image = locations[indexPath.item].businessImage
        cell.imageView.contentMode = .scaleAspectFill
        cell.titleLabel.text = locations[indexPath.item].name
        cell.addressLabel.text = locations[indexPath.item].address
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
        for item in DataModel.items {
            if item.locationId == locations[indexPath.item].objectId {
                cell.items.append(item)
                print(item.name, "found this item at this location:", locations[indexPath.row].name)
            }
            if item === DataModel.items.last {
                print("reloading")
                cell.itemCollectionView.reloadData()
            }
        }
        /*let cellMaxY = cell.frame.maxY
        let viewMaxY = placeHeaderCollectionView.frame.maxY
        cell.frame.origin.y = cell.frame.origin.y + (viewMaxY - cellMaxY)*/
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
