//
//  User.swift
//  DonationTracker
//
//  Created by Gabe Wilson on 10/1/18.
//  Copyright © 2018 Gabe Wilson. All rights reserved.
//

import Foundation
import MapKit
import Parse
//import GooglePlaces

class Location: MKPointAnnotation {
    
    var objectId: String!
    var address: String!
    var name: String!
    var domain: String!
    var locationCoordinate: PFGeoPoint!
    var locations = [Location]()
    var admin: PFUser!
    var phone: String!
    var website: String!
    
    var isRegistered: Bool!
    
    override init() {
        objectId = ""
        address = ""
        name = ""
        locationCoordinate = PFGeoPoint()
        isRegistered = false
    }
    
    init(address: String, name: String, objectId: String, locationCoordinate: PFGeoPoint) {
        self.objectId = objectId
        self.address = address
        self.name = name
        self.locationCoordinate = locationCoordinate
        self.isRegistered = false
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let otherLocation = object as? Location {
            return self.address == otherLocation.address
        }
        return false
    }
    
    func getLocations(query: PFQuery<PFObject>, completion: @escaping (_ result: [Location])->()) {
        query.includeKey("admin")
        query.findObjectsInBackground {
            (objects:[PFObject]?, error:Error?) -> Void in
            if let error = error {
                print("Error: " + error.localizedDescription)
            } else {
                if objects?.count == 0 || objects?.count == nil {
                    return
                }
                print(objects?.count, "found this many objects")
                for object in objects! {
                    let location = Location()
                    location.coordinate.latitude = object["latitude"] as! Double
                    location.coordinate.longitude = object["longitude"] as! Double
                    location.title = object["name"] as? String
                    location.subtitle = object["address"] as? String
                    location.admin = object["admin"] as? PFUser
                    location.phone = object["phone"] as? String
                    location.website = object["website"] as? String
                    print(location.admin, "this is the location admin!!")
                    //location fields
                    location.name = location.title
                    location.address = location.subtitle
                    if let domain = object["domain"] as? String {
                        print("the domain of this location ", location
                        .name, "is ", domain)
                        location.domain = domain
                    }
                    location.locationCoordinate = PFGeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                    location.objectId = object.objectId
                    location.isRegistered = true
                    self.locations.append(location)
                    if object == objects?.last {
                        completion(self.locations)
                    }
                }
            }
        }
    }
    
    
    func getLocationNames(locationsToFilter: [Location]) -> [String] {
        var names = [String]()
        for location in locationsToFilter {
            names.append(location.name)
        }
        return names
    }
    
    
    
    
}
