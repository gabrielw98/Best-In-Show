//
//  PlacesVC.swift
//  DonationTracker
//
//  Created by Gabe Wilson on 10/26/18.
//  Copyright © 2018 Gabe Wilson. All rights reserved.
//

import Foundation
import UIKit
import YelpAPI
import Parse

class PlacesVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var placeHeaderCollectionView: UICollectionView!
    @IBOutlet weak var followOutlet: UIBarButtonItem!

    @IBAction func followAction(_ sender: Any) {
                let currentLocation = locations[self.cellIndex]
        print("saving this object id!!", currentLocation.objectId)
        print("already contains this location", DataModel.locations?.contains(currentLocation))

        let locationToUpdate = PFObject(withoutDataWithClassName: "Location", objectId: currentLocation.objectId)
        locationToUpdate.add(PFUser.current()!.objectId!, forKey: "subscribers")
        locationToUpdate.saveInBackground { (success, error) in
            if success {
                print("Saved the current user as a subscriber")
                if let pulledLocations = DataModel.locations {
                    pulledLocations[(DataModel.locations?.firstIndex(of: currentLocation))!].isCurrentUserSubscribed = true
                }
                
            }
        }
    }
    
    var locations = [Location]()
    var images = [UIImage]()
    var placeImage = UIImage()
    var yelpClient: YLPClient?
    var cellIndex = 0
    
    var fromMap = false
    var selectedLocationIndex = 0
    var selectedItem = Item()
    
    override func viewWillAppear(_ animated: Bool) {
        if !fromMap {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    override func viewDidLoad() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        placeHeaderCollectionView.addGestureRecognizer(swipeRight)
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
        placeHeaderCollectionView.addGestureRecognizer(swipeLeft)
        swipeLeft.delegate = self
        swipeRight.delegate = self
        createItemCollectionViews()
        DataModel.placesRef = self
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {

            self.view.isHidden = true
            switch swipeGesture.direction {
                
            case UISwipeGestureRecognizerDirection.right:
                if cellIndex > 0 {
                    cellIndex -= 1
                }
                if selectedLocationIndex > 0 {
                    selectedLocationIndex -= 1
                }
                print("Swiped right", cellIndex)
            case UISwipeGestureRecognizerDirection.left:
                if cellIndex < locations.count - 1 {
                    cellIndex += 1
                }
                if selectedLocationIndex < locations.count - 1 {
                    selectedLocationIndex += 1
                }
                print("Swiped left", cellIndex)
            default:
                break
            }
        }
        placeHeaderCollectionView.reloadData()
        print("reloading data")
    }
    
    func createItemCollectionViews() {
        var index = 0
        for location in locations {
            if let items = DataModel.itemsPerLocation[location] {
                locations[index].items = items
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
            print(self.selectedLocationIndex, "this is the location index")
            placeHeaderCollectionView.scrollToItem(at: IndexPath(item: selectedLocationIndex, section: 0), at: .centeredHorizontally, animated: false)
        }
    }
    
    func itemSelected() {
        self.performSegue(withIdentifier: "showDetails", sender: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return locations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var newIndex: IndexPath!
        self.view.isHidden = false
        if fromMap {
            newIndex = IndexPath(item: self.selectedLocationIndex, section: 0)
            print(self.selectedLocationIndex, "using this index", locations[self.selectedLocationIndex].name, locations.count)
            if locations[selectedLocationIndex].isCurrentUserSubscribed {
                followOutlet.isEnabled = false
            } else {
                followOutlet.isEnabled = true
            }
        } else {
            newIndex = IndexPath(item: self.cellIndex, section: 0)
            print(self.cellIndex, "using this index", locations[self.cellIndex].name)
        }
        let cell = placeHeaderCollectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: newIndex) as! PlacesCollectionViewCell
        cell.imageView.layer.cornerRadius = cell.imageView.frame.height/8
        cell.imageView.layer.masksToBounds = true
        cell.imageView.backgroundColor = self.navigationController?.navigationBar.barTintColor
        cell.imageView.layer.borderWidth = 3.0
        cell.imageView.layer.borderColor = UIColor(red: 135.0/255.0, green: 206.0/255.0, blue: 235.0/255.0, alpha: 1.0).cgColor
        if fromMap {
            cell.imageView.image = locations[self.selectedLocationIndex].businessImage
            cell.imageView.contentMode = .scaleAspectFill
            cell.titleLabel.text = locations[self.selectedLocationIndex].name
            cell.addressLabel.text = locations[self.selectedLocationIndex].address
            print(self.selectedLocationIndex, "index item")
            if !locations[self.selectedLocationIndex].items.isEmpty {
                cell.itemCollectionView.isHidden = false
                cell.items = locations[self.selectedLocationIndex].items
                cell.itemCollectionView.reloadData()
            } else {
                cell.itemCollectionView.isHidden = true
            }
        } else {
            cell.imageView.image = locations[self.cellIndex].businessImage
            cell.imageView.contentMode = .scaleAspectFill
            cell.titleLabel.text = locations[self.cellIndex].name
            cell.addressLabel.text = locations[self.cellIndex].address
            if !locations[self.cellIndex].items.isEmpty {
                cell.itemCollectionView.isHidden = false
                cell.items = locations[self.cellIndex].items
                cell.itemCollectionView.reloadData()
            } else {
                cell.itemCollectionView.isHidden = true
            }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails" {
            let target = segue.destination as! ItemDetailsVC
            target.price = selectedItem.price
            target.image = selectedItem.image
            target.name = selectedItem.name
            target.tags = selectedItem.tags
        }
    }
}
