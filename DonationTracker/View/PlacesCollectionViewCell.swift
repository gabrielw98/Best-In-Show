//
//  PlacesCollectionViewItem.swift
//  DonationTracker
//
//  Created by Gabe Wilson on 10/29/18.
//  Copyright © 2018 Gabe Wilson. All rights reserved.
//

import Foundation
import UIKit
//import GooglePlaces

class PlacesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    
    
    /*func getPlaceId() ->String {
       let placesClient = GMSPlacesClient()
        placesClient.currentPlace(callback: { (placeLikelihoods, error) -> Void in
            if error != nil {
                // Handle error in some way.
            }
            
            if let placeLikelihood = placeLikelihoods?.likelihoods.first {
                let place = placeLikelihood.place
                print(place.placeID, "this is the place id")
                // Do what you want with the returned GMSPlace.
            }
        })
        return ""
    }
    
    func loadFirstPhotoForPlace(placeID: String) {
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeID) { (photos, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.localizedDescription)")
            } else {
                if let firstPhoto = photos?.results.first {
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
                self.imageView.image = photo
            }
        })
    }*/
    
}
