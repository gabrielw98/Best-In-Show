//
//  LocationInventory.swift
//  DonationTracker
//
//  Created by Gabe Wilson on 10/20/18.
//  Copyright © 2018 Gabe Wilson. All rights reserved.
//

import Foundation
import UIKit
import Parse

class LocationInventoryVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    //Clothing, Hat, Kitchen, Electronics, Household, Other starting from 0 - 5

    var selectedLocation = Location()
    var categories = ["Clothing", "Hat", "Kitchen", "Household", "Other"]
    var itemTitle = ["Adidas Shoes", "Beanie", "Set of spoons", "Chair", "Guitar"]
    var prices = ["$99.99", "$14.99", "$5.00", "$199.99", "$59.99"]
    
    @IBOutlet weak var saveButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBAction func saveLocationAction(_ sender: Any) {
        saveButtonOutlet.isEnabled = false
        //make current user global variable
        //add to global location array
        //before querying, make sure doesn't exist in location array
        print("saving this object id!!", selectedLocation.objectId)
        let locationToUpdate = PFObject(withoutDataWithClassName: "Location", objectId: selectedLocation.objectId)
        locationToUpdate.add(PFUser.current()!.objectId!, forKey: "subscribers")
        locationToUpdate.saveInBackground { (success, error) in
            if success {
                print("Saved the current user as a subscriber")
                DataModel.locations?.append(self.selectedLocation)
                
            }
        }
        
        /*if let currentUser = PFUser.current() {
            print("This is the location object id", location.objectId)
            let locationToSave = location.objectId!
            currentUser.add(locationToSave, forKey: "locations")
            currentUser.saveInBackground { (success, error) in
                if let error = error {
                    print("Error saving the location for user: \(error.localizedDescription)")
                } else if success {
                    print("Location is successfully saved for user.")
                }
            }
        }*/
    }
    
    override func viewDidLoad() {
        setupUI()
    }
    
    func setupUI() {
        //Disable the save button
        if let locations = DataModel.locations {
            for savedLocation in locations {
                if savedLocation.objectId == self.selectedLocation.objectId {
                    print("disabling the save button")
                    saveButtonOutlet.isEnabled = false
                }
            }
        }
        if DataModel.currentUserType == userType.employee {
            
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return categories[section]
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UITableViewCell()
        header.textLabel!.text = categories[section]
        header.backgroundColor = UIColor(red: 135.0/255.0, green: 206.0/255.0, blue: 235.0/255.0, alpha: 1.0)
        header.textLabel?.textColor = self.navigationController?.navigationBar.barTintColor
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 20.0)
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let itemCell = tableView.dequeueReusableCell(withIdentifier: "itemCell") as! ItemTableViewCell
        itemCell.itemImageView.image = UIImage(named: categories[indexPath.section])
        itemCell.selectionStyle = .none
        itemCell.itemNameLabel.text = itemTitle[indexPath.section]
        itemCell.itemPriceLabel.text = prices[indexPath.section]
        return itemCell
    }
    
    
    
    
    
}
