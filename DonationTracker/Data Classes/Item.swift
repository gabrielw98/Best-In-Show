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
    
    var locationItemsDict = [Location:Item]()
    
    init() {
        
    }
    
    init(object: PFObject, image: UIImage) {
        name = object["name"] as! String
        price = object["itemPrice"] as! String
        tags = object["tags"] as! [String]
        category = object["itemCategory"] as! String
        locationId = object["locationId"] as! String
        self.image = image
    }
    
    func getItemsByPerLocationDictionary(query: PFQuery<PFObject>, completion: @escaping (_ result: [Location: Item])->()) {
        query.findObjectsInBackground {
            (objects:[PFObject]?, error:Error?) -> Void in
            if let error = error {
                print("Error: " + error.localizedDescription)
            } else {
                if objects?.count == 0 || objects?.count == nil {
                    return
                }
                for object in objects! {
                    if let image = object["image"] as? PFFile {
                        image.getDataInBackground {
                            (imageData:Data?, error:Error?) -> Void in
                            if error == nil  {
                                if let finalimage = UIImage(data: imageData!) {
                                    if object["itemPrice"] != nil {
                                        //Come back take the ppoint and make it into a Location Object.
                                        self.locationItemsDict.updateValue(Item(object: object, image: finalimage), forKey: object["location"] as! Location)
                                        if object == objects!.last {
                                            completion(self.locationItemsDict)
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
}
