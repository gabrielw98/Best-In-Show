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

class PlacesVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var locations = [Location]()
    var images = [UIImage]()
    var placeImage = UIImage()
    var yelpClient: YLPClient?
    
    override func viewDidLoad() {
        print("made it to view did load")
       collectionView?.isPagingEnabled = true
        if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
        collectionView?.backgroundColor = UIColor(red: 173/255, green: 216/255, blue: 230/255, alpha: 1)
        getLocationImage()
    }
    
    func getLocationImage() {
        if let path = Bundle.main.path(forResource: "keys", ofType: "plist") {
            let keys = NSDictionary(contentsOfFile: path)
            self.yelpClient = YLPClient.init(apiKey: keys!["yelpKey"] as! String)
            let filteredPhone = "+" + locations[0].phone.onlyDigits()
            print(filteredPhone, "filtered phone number")
            yelpClient!.business(withPhoneNumber: locations[0].phone) { (results, error) in
                if error == nil {
                    if let business = results?.businesses.first {
                        print("Top business: \(business.name), id: \(business.identifier)")
                    }
                } else {
                    print("Yelp Api Error:", error!)
                }
            }
        }
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return locations.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! PlacesCollectionViewCell
        cell.imageView.layer.cornerRadius = cell.imageView.frame.height/2
        cell.imageView.layer.masksToBounds = true
        cell.imageView.backgroundColor = self.navigationController?.navigationBar.barTintColor
        cell.imageView.layer.borderWidth = 3.0
        cell.imageView.layer.borderColor = UIColor(red: 135.0/255.0, green: 206.0/255.0, blue: 235.0/255.0, alpha: 1.0).cgColor
        cell.imageView.image = self.placeImage
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
        let cellMaxY = cell.frame.maxY
        let viewMaxY = collectionView.frame.maxY
        cell.frame.origin.y = cell.frame.origin.y + (viewMaxY - cellMaxY)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let navBarHeight = navigationController!.navigationBar.frame.height
        return CGSize(width: view.frame.width, height: view.frame.height - navBarHeight)
    }
    
    func loadFirstPhotoForPlace(placeID: String) {
        print("loading photo with id", placeID)
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeID) { (photos, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.localizedDescription)")
            } else {
                print(photos?.results.count, "number of photos")
                if let firstPhoto = photos?.results.first {
                    print("got meta data")
                    self.loadImageForMetadata(photoMetadata: firstPhoto)
                }
            }
        }
    }
    
    func loadImageForMetadata(photoMetadata: GMSPlacePhotoMetadata) {
        GMSPlacesClient.shared().loadPlacePhoto(photoMetadata, callback: {
            (photo, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.localizedDescription)")
            } else {
                print("retrieved the image")
                self.placeImage = photo!
                self.collectionView?.reloadData()
                //self.attributionTextView.attributedText = photoMetadata.attributions;
                
            }
        })
    }
}
