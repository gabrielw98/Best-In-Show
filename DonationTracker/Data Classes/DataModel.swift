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
