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

class ItemFeedVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func itemFeedUnwind(segue: UIStoryboardSegue) {
        viewDidLoad()
    }
    
    var items = [Item]()
    var fromNewItem = false
    var selectedLocation = Location()
    var fromMap = false
    
    override func viewDidAppear(_ animated: Bool) {
        if fromNewItem {
            collectionView.reloadData()
            fromNewItem = false
        }
    }
    
    override func viewDidLoad() {
        collectionView.delegate = self
        collectionView.dataSource = self
        if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        }
        if fromMap {
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
            items = DataModel.items
            collectionView.reloadData()
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
        var label = UILabel(frame: CGRect(x: 0, y: self.view.layer.frame.height/8, width: 200, height: 21))
        label.textAlignment = NSTextAlignment.center
        label.text = "There are currently no items at this location"
        label.sizeToFit()
        label.textColor = UIColor.lightGray
        label.frame = CGRect(x: (self.view.frame.width - label.frame.width)/2, y: label.frame.minY, width: label.frame.width, height: label.frame.height)
        
        let callButton = UIButton(frame: CGRect(x: 0, y: self.view.layer.frame.height/6, width: 200, height: 25))
        print(self.selectedLocation.phone, "this is the phone number")
        callButton.setTitle(self.selectedLocation.phone, for: .normal)
        callButton.setTitleColor(UIColor(red: 0, green: 51/255, blue: 102/255, alpha: 1), for: .normal)
        if let url = URL(string: "tel://\(label.text)") {
            UIApplication.shared.openURL(url)
        }
        callButton.sizeToFit()
        self.view.addSubview(callButton)
        self.view.addSubview(label)
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
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowayout = collectionViewLayout as? UICollectionViewFlowLayout
        let space: CGFloat = (flowayout?.minimumInteritemSpacing ?? 0.0) + (flowayout?.sectionInset.left ?? 0.0) + (flowayout?.sectionInset.right ?? 0.0)
        let size:CGFloat = (collectionView.frame.size.width - space) / 2.0
        return CGSize(width: size, height: size)
    }
    
}
