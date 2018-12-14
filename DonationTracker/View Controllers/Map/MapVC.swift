//
//  MapVC.swift
//  DonationTracker
//
//  Created by Gabe Wilson on 10/2/18.
//  Copyright © 2018 Gabe Wilson. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import Parse

class MapVC: UIViewController, CLLocationManagerDelegate, UISearchControllerDelegate, UISearchBarDelegate, MKMapViewDelegate {
    
    var chosenFilter = ""
    @IBAction func mapUnwind(segue: UIStoryboardSegue) {
        print(chosenFilter, "this is the chosen filter")
        let query = PFQuery(className: "Item")
        query.whereKey("itemCategory", equalTo: chosenFilter)
        Item().getItemsByPerLocationDictionary(query: query, completion: { (itemsPerLocationDict) in
            for grouping in itemsPerLocationDict {
                print("Here", grouping)
                //for each location put it into the map
            }
        })
    }
    
    @IBAction func addItemAction(_ sender: Any) {
        self.performSegue(withIdentifier: "showAddItem", sender: nil)
    }
    @IBAction func searchItemAction(_ sender: Any) {
        if isLocationSearch {
            navigationItem.searchController = self.searchController
            isLocationSearch = false
            navigationItem.searchController = searchController
            self.searchController.isActive = true
            navigationItem.searchController?.searchBar.placeholder = "Search Items"
            searchItemOutlet.tintColor = UIColor.white
            searchLocationOutlet.tintColor = UIColor.lightGray
        } else if searchItemOutlet.tintColor == UIColor.lightGray && !isLocationSearch {
            navigationItem.searchController = self.searchController
            searchItemOutlet.tintColor = UIColor.white
            
        } else if !isLocationSearch {
            searchItemOutlet.tintColor = UIColor.lightGray
            showOriginalLocations()
        }
    }
    
    @IBAction func searchLocationAction(_ sender: Any) {
        if !isLocationSearch {
            navigationItem.searchController = self.searchController
            isLocationSearch = true
            navigationItem.searchController = searchController
            self.searchController.isActive = true
            navigationItem.searchController?.searchBar.placeholder = "Search Locations"
            searchLocationOutlet.tintColor = UIColor.white
            searchItemOutlet.tintColor = UIColor.lightGray
        } else {
            isLocationSearch = false
            searchLocationOutlet.tintColor = UIColor.lightGray
            showOriginalLocations()
        }
    }
    
    
    @IBOutlet weak var searchItemOutlet: UIBarButtonItem!
    @IBOutlet weak var searchLocationOutlet: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    
    var locationDict = [String : Location]()
    var locationManager = CLLocationManager()
    var searchController: UISearchController!
    var selectedLocation: Location!
    var isLocationSearch = true
    
    override func viewDidLoad() {
        if let path = Bundle.main.path(forResource: "keys", ofType: "plist") {
            let keys = NSDictionary(contentsOfFile: path)
            print(keys!["sendGridKey"] as! String)
        }
        var userNotificationTypes : UIUserNotificationType
        userNotificationTypes = [.alert , .badge , .sound]
        let notificationSettings = UIUserNotificationSettings.init(types: userNotificationTypes, categories: nil)
        UIApplication.shared.registerUserNotificationSettings(notificationSettings)
        UIApplication.shared.registerForRemoteNotifications()
        mapView.delegate = self
        locationServices()
        setupSearchBar()
        queryAllLocations()
    }
    
    
    func locationServices() {
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first!
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 500, 500)
        mapView.setRegion(coordinateRegion, animated: false)
        mapView.showsUserLocation = true
        locationManager.stopUpdatingLocation()
    }
    
    func setupSearchBar() {
        if #available(iOS 11.0, *) {
            let sc = UISearchController(searchResultsController: nil)
            sc.delegate = self
            let searchBar = sc.searchBar
            searchBar.tintColor = UIColor.white
            searchBar.barTintColor = UIColor.white
            searchBar.delegate = self
            searchBar.placeholder = "Search Locations"
            if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
                textfield.textColor = mapView.tintColor
                if let backgroundview = textfield.subviews.first {
                    
                    // Background color
                    backgroundview.backgroundColor = UIColor.white
                    
                    // Rounded corner
                    backgroundview.layer.cornerRadius = 10;
                    backgroundview.clipsToBounds = true;
                    
                }
            }
            
            if let navigationbar = self.navigationController?.navigationBar {
                navigationbar.barTintColor = mapView.tintColor
            }
            navigationItem.hidesSearchBarWhenScrolling = false
            self.searchController = sc
            navigationItem.searchController = self.searchController
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("just performed search")
        mapView.removeAnnotations(mapView.annotations)
        if isLocationSearch {
            //Come back
            // Filter the map by the all locations that match the query
            // annotations should be white or navy blue.
            let query = PFQuery(className: "Locations")
            query.whereKey("name", matchesRegex: self.searchController.searchBar.text!)
            Location().getLocations(query: query, completion: { (locationObjects) in
                self.locationDict.removeAll()
                for searchLocation in locationObjects {
                    self.locationDict.updateValue(searchLocation, forKey: searchLocation.address)
                    if searchLocation == locationObjects.last {
                        self.mapView.addAnnotations(self.locationDict.compactMap(){ $0.1 }  )
                        self.mapView.showAnnotations(self.locationDict.compactMap(){ $0.1 }, animated: false)
                        self.mapView.region = MKCoordinateRegion(center: ((self.locationDict[searchLocation.address])?.coordinate)!, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
                    }
                }
            })
            // OR
            query.whereKey("address", matchesRegex: self.searchController.searchBar.text!)
        } else {
            //Come back
            // create a dictionary of Location objects (key from the pointer) and items that
            // are found at those respective locations.
            // present those locations with a different color (navy blue or white) and when the user selects
            // the location, he or she should see just the items that were retrieved from their query.
            let query = PFQuery(className: "Item")
            //change to location pointer
            query.selectKeys(["locationId"])
            //query.includeKey("location")
            query.order(byDescending: "createdAt")
            query.whereKey("tags", contains: self.searchController.searchBar.text)
            query.findObjectsInBackground { (objects, error) in
                
            }
        }
    }
    
    
    func showOriginalLocations() {
        print("showing original locations")
        navigationItem.searchController = nil
        //navigationItem.searchController?.searchBar.isHidden = true
        //Come back
        //REMOVE Search here
        self.locationDict.removeAll()
        if let locations = DataModel.locations {
            for location in locations {
                self.locationDict.updateValue(location, forKey: location.address)
                if location == locations.last {
                    self.mapView.addAnnotations(self.locationDict.compactMap(){ $0.1 }  )
                    self.mapView.showAnnotations(self.locationDict.compactMap(){ $0.1 }, animated: false)
                    self.mapView.region = MKCoordinateRegion(center: ((self.locationDict[location.address])?.coordinate)!, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
                }
            }
        }
    }
    
    func queryAllLocations() {
        //Come back
        // This query gets all of the locations the user is subscribed to
        // Instead of querying all the locations in the map vc,
        // query all locations in the map vc and for those that the user is subscribed to,
        // get the items. put them in the DataModel.items to show in ItemsVC.
        // Otherwise, only show items from locations when the user selects ()
        // Thus, don't use do an additional query when showing a location that the user
        // is registered to.
        let query = PFQuery(className: "Location")
        //query.whereKey("coordinate", nearGeoPoint: PFGeoPoint(latitude: self.mapView.userLocation.coordinate.latitude, longitude: self.mapView.userLocation.coordinate.longitude) , withinMiles: 10.0)
        Location().getLocations(query: query, completion: { (locationObjects) in
            DataModel.locations = locationObjects
            self.locationDict.removeAll()
            if let locations = DataModel.locations {
                var ids = [String]()
                for location in locations {
                    self.locationDict.updateValue(location, forKey: location.address)
                    if location.isCurrentUserSubscribed {
                        ids.append(location.objectId)
                    }
                    if location == locations.last {
                        let query = PFQuery(className: "Item")
                        print("these are the ids", ids)
                        query.whereKey("locationId", containedIn: ids)
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
                                                            DataModel.items.append(Item(object: object, image: finalimage))
                                                            print(DataModel.items.count)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        })
                        self.mapView.addAnnotations(self.locationDict.compactMap(){ $0.1 }  )
                        self.mapView.showAnnotations(self.locationDict.compactMap(){ $0.1 }, animated: false)
                        self.mapView.region = MKCoordinateRegion(center: ((self.locationDict[location.address])?.coordinate)!, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
                    }
                }
            }
        })
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        self.selectedLocation = view.annotation as? Location
        self.performSegue(withIdentifier: "showItemFeedVC", sender: nil)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        print("AFter")
        let identifier = "annotation"
        var annotationView = MKMarkerAnnotationView()
        if let dequedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            annotationView = dequedView
        } else{
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        if let location = annotation as? Location {
            print("Made this location here", location.subtitle!, location.isRegistered!)
            if location.isRegistered {
                print("found a registered ")
                annotationView.markerTintColor = UIColor(red: 135.0/255.0, green: 206.0/255.0, blue: 235.0/255.0, alpha: 1.0)
                annotationView.canShowCallout = true
                let infoButton = Sender(type: .infoLight)
                annotationView.rightCalloutAccessoryView = infoButton
                infoButton.buttonIdentifier = location.subtitle
                infoButton.addTarget(self, action: #selector(MapVC.showLocation(sender:)), for: UIControlEvents.touchUpInside)
            }
        }
        return annotationView
    }
    
    
    @objc func showLocation(sender: Sender) {
        print(sender.buttonIdentifier!, "sender param")
        self.selectedLocation = locationDict[sender.buttonIdentifier!]
        print(selectedLocation, "selected this one")
        for location in locationDict {
            print(location.value.subtitle, "address")
        }
        self.performSegue(withIdentifier: "showRegisteredLocationDetails", sender: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRegisteredLocationDetails" {
            let targetVC = segue.destination as! LocationInventoryVC
            print(self.selectedLocation.objectId, "this is the selected location objectId")
            targetVC.selectedLocation = self.selectedLocation
        } else if segue.identifier == "toCollectionView" {
            //let destination = segue.destination as! CollectionVC
        } else if segue.identifier == "showItemFeedVC" {
            let targetVC = segue.destination as! ItemFeedVC
            targetVC.selectedLocation = self.selectedLocation
            targetVC.fromMap = true
        }
    }
    
    
    @IBAction func collectionViewButton(_ sender: Any) {
        performSegue(withIdentifier: "toCollectionView", sender: self)
    }
}

class Sender: UIButton {
    var buttonIdentifier: String?
}




