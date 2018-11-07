//
//  DataModel.swift
//  DonationTracker
//
//  Created by Gabe Wilson on 10/30/18.
//  Copyright © 2018 Gabe Wilson. All rights reserved.
//

import Foundation
import UIKit

struct DataModel {
    static var locations: [Location]?
    static var currentUserType = userType.user
    static var employeeStatus = ""
}

enum userType {
    case user
    case employee
    case admin
}
