//
//  ItemFeedVC.swift
//  DonationTracker
//
//  Created by Gabe Wilson on 11/19/18.
//  Copyright © 2018 Gabe Wilson. All rights reserved.
//

import Foundation
import UIKit
import Parse

class ItemFeedVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
    
    
    @IBOutlet weak var filterOutlet: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBAction func filterAction(_ sender: Any) {
        if filterOutlet.image == UIImage(named: "FilterMinus") {
            filterOutlet.image = UIImage(named: "Filter")
            self.navigationItem.title = ""
            self.selectedFilter = ""
            self.collectionView.reloadData()
        } else {
            self.performSegue(withIdentifier: "showFilterVC", sender: nil)
        }
        
    }
    
    
    @IBAction func itemFeedUnwind(segue: UIStoryboardSegue) {
        print("filtering by", self.selectedFilter)
        if segue.identifier == "itemFeedFilterUnwind" {
            filterOutlet.image = UIImage(named: "FilterMinus")
            filteredItems.removeAll()
            filteredItems = items.filter { (Item) -> Bool in
                Item.category == selectedFilter
            }
        }
        viewDidLoad()
    }
    
    var items = [Item]()
    var fromNewItem = false
    var selectedLocation = Location()
    var fromMap = false
    
    //Filter Fields
    var filteredItems = [Item]()
    var selectedFilter = ""
    
    var selectedItem = Item()
    
    override func viewDidAppear(_ animated: Bool) {
        if fromNewItem {
            collectionView.reloadData()
            fromNewItem = false
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = self.selectedFilter
    }
    
    @objc func toggleEdit() {
        if collectionView.allowsMultipleSelection {
            if (self.navigationItem.rightBarButtonItems?.count)! > 1 {
                self.navigationItem.rightBarButtonItems?.remove(at: 1)
            }
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(toggleEdit))
            collectionView.allowsMultipleSelection = false
        } else {
            let removeItems = UIBarButtonItem(title: "Remove", style: .plain, target: self, action: #selector(deleteItems))
            removeItems.isEnabled = false
            navigationItem.rightBarButtonItems?.append(removeItems)
            
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(toggleEdit))
            collectionView.allowsMultipleSelection = true
        } 
        
    }
    
    override func viewDidLoad() {
        if DataModel.employeeStatus == "Registered" {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(toggleEdit))
        }
        collectionView.delegate = self
        collectionView.dataSource = self
        if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        }
        if fromMap {
            self.title = selectedLocation.name
            if selectedLocation.isCurrentUserSubscribed {
                self.items = [Item]()
                for item in DataModel.items {
                    if item.locationId == self.selectedLocation.objectId {
                        self.items.append(item)
                        collectionView.reloadData()
                    }
                }
                if self.items.isEmpty {
                    self.showNoItemsLabel()
                }
            } else {
                queryItems()
            }
        } else {
            if DataModel.firstTimeUser {
                print("first time user found")
                self.items = DataModel.items
            } else {
                print("not first time user found")
                for item in DataModel.subscribedLocations {
                    print("item:", item.name!)
                }
                DataModel.getItemsFromSubscribedLocation()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { // change 2 to desired number of seconds
                    self.items = DataModel.subscribedItems
                    self.collectionView.reloadData()
                }
                
            }
            //Come back
            //Query items here... FOR FIRST TIME USER
        }
    }
    
    func queryItems() {
        let query = PFQuery(className: "Item")
        print("query id:", self.selectedLocation.objectId!)
        query.whereKey("objectId", equalTo: self.selectedLocation.objectId!)
        query.findObjectsInBackground {
            (objects:[PFObject]?, error:Error?) -> Void in
            if let error = error {
                print("Error: " + error.localizedDescription)
            } else {
                if objects?.count == 0 || objects?.count == nil {
                    self.showNoItemsLabel()
                    return
                }
                for object in objects! {
                    if let image = object["image"] as? PFFile {
                        image.getDataInBackground {
                            (imageData:Data?, error:Error?) -> Void in
                            if error == nil  {
                                if let finalimage = UIImage(data: imageData!) {
                                    if object["itemPrice"] != nil {
                                        print("items found3")
                                        //Put into sqlite
                                        DataModel.items.append(Item(object: object, image: finalimage))
                                        if object == objects!.last {
                                            self.collectionView.reloadData()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func showNoItemsLabel() {
        //Add google maps image for the place
        let locationImageView = UIImageView(frame: CGRect(x: 0, y: self.view.layer.frame.height/8, width: self.view.frame.width/2, height: self.view.frame.width/2))
        locationImageView.image = UIImage(named: "DefaultLocation")
        locationImageView.sizeToFit()
        locationImageView.frame = CGRect(x: (self.view.frame.width - locationImageView.frame.width)/2, y: locationImageView.frame.minY, width: locationImageView.frame.width, height: locationImageView.frame.height)
        let label = UILabel(frame: CGRect(x: 0, y: self.view.layer.frame.height/8 + locationImageView.frame.height + 20, width: 200, height: 21))
        label.textAlignment = NSTextAlignment.center
        label.text = "There are currently no items at this location"
        label.sizeToFit()
        label.textColor = UIColor.lightGray
        label.frame = CGRect(x: (self.view.frame.width - label.frame.width)/2, y: label.frame.minY, width: label.frame.width, height: label.frame.height)
        let callButton = UIButton(frame: CGRect(x: 0, y: self.view.layer.frame.height/6 + locationImageView.frame.height + 20, width: 200, height: 25))
        print(self.selectedLocation.phone, "this is the phone number")
        callButton.setTitle(self.selectedLocation.phone, for: .normal)
        callButton.setTitleColor(UIColor(red: 0, green: 51/255, blue: 102/255, alpha: 1), for: .normal)
        callButton.addTarget(self, action: #selector(ItemFeedVC.makeCall(sender:)), for: .touchUpInside)
        callButton.sizeToFit()
        callButton.frame = CGRect(x: (self.view.frame.width - callButton.frame.width)/2, y: callButton.frame.minY, width: callButton.frame.width, height: callButton.frame.height)
        self.view.addSubview(callButton)
        self.view.addSubview(label)
        self.view.addSubview(locationImageView)
    }
    
    @objc func makeCall(sender: UIButton) {
        sender.titleLabel?.text?.makeACall()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.selectedFilter == "" {
            return items.count
        } else {
            return filteredItems.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ItemCell
        if self.selectedFilter == "" {
            cell.priceLabel.text = items[indexPath.item].price
            cell.imageView.image = items[indexPath.item].image
            if items[indexPath.row].isLongPressed {
                cell.imageView.alpha = 0.5
            }
        } else { //show filtered items
            cell.priceLabel.text = filteredItems[indexPath.item].price
            cell.imageView.image = filteredItems[indexPath.item].image
            if filteredItems[indexPath.item].isLongPressed {
                cell.imageView.alpha = 0.5
            }
        }
        /*let tapGR = CustomLongTapGestureRecongnizer(target: self, action: #selector(handleTap(sender:)))
        tapGR.indexPath = indexPath
        tapGR.delegate = self
        cell.addGestureRecognizer(tapGR)*/
        cell.priceBackground.alpha = 0.6
        return cell
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc func handleTap(sender: CustomLongTapGestureRecongnizer) {
        print("long pressed")
        if self.selectedFilter == "" {
            items[sender.indexPath.item].isLongPressed = true
        } else {
            filteredItems[sender.indexPath.item].isLongPressed = true
        }
        self.collectionView.reloadItems(at: [sender.indexPath])
        return
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.selectedFilter == "" {
            selectedItem = items[indexPath.item]
        } else {
            selectedItem = filteredItems[indexPath.item]
        }
        if !collectionView.allowsMultipleSelection {
            self.performSegue(withIdentifier: "showDetails", sender: nil)
            collectionView.deselectItem(at: indexPath, animated: true)
        } else {
            print("count:", collectionView.indexPathsForSelectedItems?.count)
            if collectionView.allowsMultipleSelection && (collectionView.indexPathsForSelectedItems?.count)! >= 1 {
                navigationItem.rightBarButtonItems![1].isEnabled = true
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView.allowsMultipleSelection && (collectionView.indexPathsForSelectedItems?.count)! == 0 {
            navigationItem.rightBarButtonItems![1].isEnabled = false
        }
    }
    
    
    @objc func deleteItems() {
            print("trying to remove")
            var idArray = [String]()
            for indexPath in (collectionView!.indexPathsForSelectedItems as? [IndexPath])! {
                idArray.append(items[indexPath.row].objectId)
            }
            let query = PFQuery(className: "Item")
            query.whereKey("objectId", containedIn: idArray)
            query.findObjectsInBackground {
                (objects:[PFObject]?, error:Error?) -> Void in
                PFObject.deleteAll(inBackground: objects, block: { (success:Bool, error:Error?) in
                    if success {
                        print("Success: Deleted the objects")
                    }
                })
            }
            items.removeAll { (Item) -> Bool in
                idArray.contains(Item.objectId)
            }
            collectionView.reloadData()
            toggleEdit()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFilterVC" {
            let navController = segue.destination as! UINavigationController
            let target = navController.topViewController as! FilterCategoriesVC
            target.itemFieldFilter = true
        } else if segue.identifier == "showDetails" {
            let target = segue.destination as! ItemDetailsVC
            target.name = self.selectedItem.name
            target.image = self.selectedItem.image
            target.price = self.selectedItem.price
            target.tags = self.selectedItem.tags
        }
    }
    
}

class CustomLongTapGestureRecongnizer: UITapGestureRecognizer {
    var indexPath = IndexPath()
}
