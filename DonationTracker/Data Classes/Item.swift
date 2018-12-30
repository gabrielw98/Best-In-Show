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
    var objectId = ""
        
    var isLongPressed = false

    var locationItemsDict = [Location:[Item]]()
    
    init() {
        
    }
    
    init(object: PFObject, image: UIImage) {
        print(object.objectId, "id!!!!")
        name = object["name"] as! String
        price = object["itemPrice"] as! String
        tags = object["tags"] as! [String]
        category = object["itemCategory"] as! String
        locationId = object["locationId"] as! String
        objectId = object.objectId!
        self.image = image
    }
    
    func getItemsByPerLocationDictionary(query: PFQuery<PFObject>, completion: @escaping (_ result: [Location: [Item]])->()) {
        locationItemsDict.removeAll()
        query.includeKey("location")
        query.findObjectsInBackground {
            (objects:[PFObject]?, error:Error?) -> Void in
            if let error = error {
                print("Error: " + error.localizedDescription)
            } else {
                if objects?.count == 0 || objects?.count == nil {
                    return
                }
                print(objects?.count, "objects count")
                for object in objects! {
                    if let image = object["image"] as? PFFile {
                        image.getDataInBackground {
                            (imageData:Data?, error:Error?) -> Void in
                            if error == nil  {
                                if let finalimage = UIImage(data: imageData!) {
                                    if object["itemPrice"] != nil {
                                        //Come back take the point and make it into a Location Object.
                                        var location: Location!
                                        if let image = (object["location"] as! PFObject)["image"] as? PFFile {
                                            image.getDataInBackground {
                                                (imageData:Data?, error:Error?) -> Void in
                                                location = Location(object: object["location"] as! PFObject, image: UIImage(named: "AppIconLocation")!)
                                                self.populateItemsPerLocationDict(item: Item(object: object, image: finalimage), location: location)
                                                var itemCount = 0
                                                for itemArray in self.locationItemsDict.values {
                                                    itemCount += itemArray.count
                                                }
                                                if itemCount == objects!.count {
                                                    print("done1", self.locationItemsDict.count)
                                                    for key in self.locationItemsDict.keys {
                                                        for item in self.locationItemsDict[key]! {
                                                            print("key:", key.name, "item:", item.name, item.category)
                                                        }
                                                    }
                                                    completion(self.locationItemsDict)
                                                }
                                            }
                                        } else {
                                            location = Location(object: object["location"] as! PFObject, image: UIImage(named: "AppIconLocation")!)
                                            self.populateItemsPerLocationDict(item: Item(object: object, image: finalimage), location: location)
                                            if self.locationItemsDict.values.count == objects!.count {
                                                print("done2", self.locationItemsDict.count)
                                                for key in self.locationItemsDict.keys {
                                                    for item in self.locationItemsDict[key]! {
                                                        print("key:", key.name!, "item:", item.name, item.category)
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
        }
    }
    
    func populateItemsPerLocationDict(item: Item, location: Location) {
        print("inside populate")
        var items = self.locationItemsDict[location]
        if items == nil {
            items = [item]
            print(item.name, location.name!)
            self.locationItemsDict.updateValue(items!, forKey: location)
        } else {
            items?.append(item)
            for item in items! {
                print("item:", item.name)
            }
            self.locationItemsDict.updateValue(items!, forKey: location)
        }
    }
    
    func queryRecommendedItems(query: PFQuery<PFObject>, completion: @escaping (_ result: [Item])->()) {
        query.findObjectsInBackground { (objects, error) in
            var recommendedItems = [Item]()
            if error == nil {
                if objects != nil && !(objects?.isEmpty)! {
                    for object in objects! {
                        print("FINAL OBJECTS Count", objects!.count)
                        if let image = object["image"] as? PFFile {
                            image.getDataInBackground {
                                (imageData:Data?, error:Error?) -> Void in
                                if let finalimage = UIImage(data: imageData!) {
                                    recommendedItems.append(Item(object: object, image: finalimage))
                                    print(recommendedItems.count)
                                    if recommendedItems.count == objects?.count {
                                        completion(recommendedItems)
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


