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

    //Add Item data
    static var category = ""
    static var name = ""
    static var price = ""
    static var tags = [String]()
    static var employeeWorkPlace = "M8zrpFJD8f"
    
    static var employees: [PFUser]?
    static var requests: [PFUser]?
    static var items = [Item]()
    
    static var currentAddItemPage = "Name"
    
    static func resetAddData() {
        category = ""
        name = ""
        price = ""
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
