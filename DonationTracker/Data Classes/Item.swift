//
//  Item.swift
//  DonationTracker
//
//  Created by Gabe Wilson on 11/22/18.
//  Copyright © 2018 Gabe Wilson. All rights reserved.
//

import Foundation
import Parse

class Item {
    
    var name = ""
    var price = ""
    var tags = [String]()
    var category = ""
    var image = UIImage()
    var locationId = ""
    
    init(object: PFObject, image: UIImage) {
        name = object["name"] as! String
        price = object["itemPrice"] as! String
        tags = object["tags"] as! [String]
        category = object["itemCategory"] as! String
        locationId = object["locationId"] as! String
        self.image = image
    }
    
}
