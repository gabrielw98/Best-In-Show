//
//  DataModel.swift
//  DonationTracker
//
//  Created by Gabe Wilson on 10/30/18.
//  Copyright © 2018 Gabe Wilson. All rights reserved.
//

import Foundation
import UIKit
import Parse

struct DataModel {
    static var locations: [Location]?
    static var currentUserType = userType.user
    static var employeeStatus = ""
    static var adminStatus = ""
    static var itemsPerLocation = [Location:[Item]]()
    static var firstTimeUser = false

    //Add Item data
    static var category = ""
    static var name = ""
    static var price = ""
    static var tags = [String]()
    static var employeeWorkPlace = ""
    
    static var employees: [PFUser]?
    static var requests: [PFUser]?
    static var items = [Item]()
    
    static var placesRef = PlacesVC()
    
    static var currentAddItemPage = "Name"
    static var deviceToken = Data()
    
    static var fromPush = false
    static var pushObjectId = ""

    static var subscribedLocations = [Location]()
    static var itemsPerSubscribedLocation = [Location:[Item]]()
    static var subscribedItems = [Item]()
    
    static func resetAddData() {
        category = ""
        name = ""
        price = ""
    }
    
    static func createItemsPerLocationDict() {
        //Come back - make this more efficient n^2
        for location in locations! {
            for item in self.items {
                if item.locationId == location.objectId {
                    if var itemsAtLocation = itemsPerLocation[location] { //filled item array
                        itemsAtLocation.append(item)
                        self.itemsPerLocation.updateValue(itemsAtLocation, forKey: location)
                    } else { //empty item array
                        self.itemsPerLocation.updateValue([Item](), forKey: location)
                        itemsPerLocation[location]?.append(item)
                    }
                }
            }
        }
        print("dict")
        for key in itemsPerLocation.keys {
            for item in itemsPerLocation[key]! {
                print(key.name + ":", item.name)
            }
        }
    }
    
    static func getItemsFromSubscribedLocation() {
        let query = PFQuery(className: "Item")
        print("these are the ids", DataModel.subscribedLocations.map { $0.objectId })
        query.whereKey("locationId", containedIn: DataModel.subscribedLocations.map { $0.objectId })
        query.whereKeyExists("image")
        query.findObjectsInBackground(block: { (objects, error) in
            if let error = error {
                print(error)
            } else if let objects = objects {
                if objects.isEmpty {
                    print("No Items Found")
                } else {
                    print(objects.count, "this is the count of the objects!")
                    for object : PFObject in objects {
                        if let image = object["image"] as? PFFile {
                            image.getDataInBackground {
                                (imageData:Data?, error:Error?) -> Void in
                                if error == nil  {
                                    if let finalimage = UIImage(data: imageData!) {
                                        if object["itemPrice"] != nil {
                                            print("items found2")
                                            //Put into sqlite
                                            DataModel.subscribedItems.append(Item(object: object, image: finalimage))
                                            print(DataModel.items.count)
                                            if DataModel.subscribedItems.count == objects.count {
                                                DataModel.createItemsPersSubscribedLocationDict()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        })
    }
    
    static func createItemsPersSubscribedLocationDict() {
        //Come back - make this more efficient n^2
        for location in subscribedLocations {
            for item in self.subscribedItems {
                if item.locationId == location.objectId {
                    if var itemsAtLocation = itemsPerSubscribedLocation[location] { //filled item array
                        itemsAtLocation.append(item)
                        self.itemsPerLocation.updateValue(itemsAtLocation, forKey: location)
                    } else { //empty item array
                        self.itemsPerSubscribedLocation.updateValue([Item](), forKey: location)
                        itemsPerSubscribedLocation[location]?.append(item)
                    }
                }
            }
        }
        print("dict")
        for key in itemsPerLocation.keys {
            for item in itemsPerLocation[key]! {
                print(key.name + ":", item.name)
            }
        }
    }
    
    static func getItemsFromLocation(location: Location) -> [Item] {
        return itemsPerLocation[location]!
    }
    
    static func getSubscribedLocations() -> [Location] {
        return (locations?.filter({ (Location) -> Bool in
            Location.isCurrentUserSubscribed
        }))!
    }
}

enum userType {
    case user
    case employee
    case admin
}

extension StringProtocol where Index == String.Index {
    func index(of string: Self, options: String.CompareOptions = []) -> Index? {
        return range(of: string, options: options)?.lowerBound
    }
    func endIndex(of string: Self, options: String.CompareOptions = []) -> Index? {
        return range(of: string, options: options)?.upperBound
    }
}
