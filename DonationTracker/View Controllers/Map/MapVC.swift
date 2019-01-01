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
import UserNotifications

class MapVC: UIViewController, CLLocationManagerDelegate, UISearchControllerDelegate, UISearchBarDelegate, MKMapViewDelegate {
    
    var chosenFilter = ""
    @IBAction func mapUnwind(segue: UIStoryboardSegue) {
        print(chosenFilter, "this is the chosen filter")
        if self.chosenFilter != "" {
            let query = PFQuery(className: "Item")
            query.whereKey("itemCategory", equalTo: chosenFilter)
            Item().getItemsByPerLocationDictionary(query: query, completion: { (itemsPerLocationDict) in
                self.populateMapWithLocationDict(dict: itemsPerLocationDict)
            })
        }
    }
    
    func populateMapWithLocationDict(dict: [Location:[Item]]) {
        mapView.removeAnnotations(mapView.annotations)
        self.mapView.addAnnotations(dict.keys.compactMap(){$0} )
        self.mapView.showAnnotations(dict.keys.compactMap() {$0}, animated: false)
        print(dict.keys.compactMap(){$0}[0].name!, "centering map around this location")
    }
    
    @IBAction func addItemAction(_ sender: Any) {
        self.mapToNewItemCategory = true
        self.performSegue(withIdentifier: "toCollectionView", sender: nil)
    }
    @IBAction func searchItemAction(_ sender: Any) {
        print(searchItemOutlet.tintColor == UIColor.lightGray, searchItemOutlet.tintColor == UIColor.white, "color")
        if isLocationSearch {
            isLocationSearch = false
            self.searchController.isActive = true
            navigationItem.searchController?.searchBar.placeholder = "Search Items"
            searchItemOutlet.tintColor = UIColor.white
            searchLocationOutlet.tintColor = UIColor.lightGray
            DispatchQueue.main.async {
                self.searchController.isActive = true
                self.searchController.searchBar.becomeFirstResponder()
            }
        } else if searchItemOutlet.tintColor == UIColor.lightGray {
            navigationItem.searchController = self.searchController
            print("in here but not working")
            isLocationSearch = false
            self.searchController.isActive = true
            navigationItem.searchController?.searchBar.placeholder = "Search Items"
            searchItemOutlet.tintColor = UIColor.white
            searchLocationOutlet.tintColor = UIColor.lightGray
            DispatchQueue.main.async {
                self.searchController.isActive = true
                self.searchController.searchBar.becomeFirstResponder()
            }
            
        } else if searchItemOutlet.tintColor == UIColor.white {
            searchItemOutlet.tintColor = UIColor.lightGray
            showOriginalLocations()
        }
    }
    
    @IBAction func searchLocationAction(_ sender: Any) {
        print("isLocationSearch?", isLocationSearch)
        if !isLocationSearch {
            navigationItem.searchController = self.searchController
            isLocationSearch = true
            navigationItem.searchController = searchController
            navigationItem.searchController?.searchBar.placeholder = "Search Locations"
            //Come back
            DispatchQueue.main.async {
                self.searchController.isActive = true
                self.searchController.searchBar.becomeFirstResponder()
            }
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
    var firstTimeUser = false
    var currentLocation = CLLocationCoordinate2D()
    
    //Filter Fields
    var mapToFilterItemCategory = false
    var mapToNewItemCategory = false
    
    var showItemFeedVC = false
    
    override func viewWillAppear(_ animated: Bool) {
        if showItemFeedVC {
            self.tabBarController?.selectedIndex = 1
        }
        showItemFeedVC = false
    }
    
    override func viewDidLoad() {
        //showPush()
        //cloudPush()
        UIApplication.shared.applicationIconBadgeNumber = 0
        if let path = Bundle.main.path(forResource: "keys", ofType: "plist") {
            let keys = NSDictionary(contentsOfFile: path)
            print(keys!["sendGridKey"] as! String)
        }
        if DataModel.employeeWorkPlace == "" {
            self.navigationItem.rightBarButtonItem = nil
        }
        
        var userNotificationTypes : UIUserNotificationType
        userNotificationTypes = [.alert , .badge , .sound]
        let notificationSettings = UIUserNotificationSettings.init(types: userNotificationTypes, categories: nil)
        UIApplication.shared.registerUserNotificationSettings(notificationSettings)
        UIApplication.shared.registerForRemoteNotifications()
        mapView.delegate = self
        searchItemOutlet.tintColor = UIColor.lightGray
        locationServices()
        setupSearchBar()
        let sb = UIStoryboard(name: "Main", bundle: nil)
        /*let otherVC = sb.instantiateViewController(withIdentifier: "ItemDetailsVC") as! ItemDetailsVC
        let navController = sb.instantiateViewController(withIdentifier: "DetailsNav") as! UINavigationController
        */
        
        
        let itemVC : ItemDetailsVC = sb.instantiateViewController(withIdentifier: "ItemDetailsVC") as! ItemDetailsVC
        let navigationController = UINavigationController(rootViewController: itemVC)
        //self.present(navigationController, animated: true)
        //window?.rootViewController = navigationController;
        /*
        let newVC = self.storyboard?.instantiateViewController(withIdentifier: "ItemDetailsVC")
        self.definesPresentationContext = true
        newVC?.modalPresentationStyle = .overCurrentContext
        self.present(newVC!, animated: true, completion: nil)*/
    }
    
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler:
        @escaping (UIBackgroundFetchResult) -> Void) {
        self.tabBarController?.selectedIndex = 1
        print("made it inside here!!! got push")
        //let vc = sb.instantiateViewController(withIdentifier: "ItemDetailsVC") as! ItemDetailsVC
        //navigationController.pushViewController(vc, animated: true)
        //tabBarVC.present(newVC, animated: true, completion: nil)
        //self.present(navigationController, animated: true)
        //window?.rootViewController = navigationController
    }
    
    func cloudPush() {
        PFCloud.callFunction(inBackground: "pushToUser", withParameters: ["recipientId":"4GLzZP49bv", "message": "Message from \(PFUser.current()!.username!)"]){
            (response, error) in
            if error == nil {
                // Do something with response
                print(response, "response")
            } else {
                // Handle with error
                print(error?.localizedDescription, "Cloud Code Push Error")
            }
        }
    }
    
    func showPush() {
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "Entered the map view", arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: "Check out some of the stores with great deals!",
                                                                arguments: nil)
        
        // Configure the trigger for a 7am wakeup.
        var dateInfo = DateComponents()
        dateInfo.nanosecond = 10
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateInfo, repeats: false)
        
        // Create the request object.
        let request = UNNotificationRequest(identifier: "Local Notification", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error) in
            if error == nil {
                print("Push from here.")
            }
        }
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
        currentLocation = (locations.first?.coordinate)!
        locationManager.stopUpdatingLocation()
        if firstTimeUser {
            print("querying follow nearby")
            queryAndFollowNearyby()
            firstTimeUser = false
        } else {
            queryAllLocations()
        }
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
                    backgroundview.backgroundColor = UIColor.white
                    backgroundview.layer.cornerRadius = 10
                    backgroundview.clipsToBounds = true
                }
            }
            if let navigationbar = self.navigationController?.navigationBar {
                navigationbar.barTintColor = mapView.tintColor
            }
            navigationItem.hidesSearchBarWhenScrolling = false
            self.searchController = sc
            //navigationItem.searchController = self.searchController
            isLocationSearch = false
            navigationItem.searchController = nil
        }
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        self.definesPresentationContext = true
        DispatchQueue.main.async {
            searchController.searchBar.becomeFirstResponder()
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
            let map = self.mapView
            Location().getLocationsInMapScope(mapView: map!, completion: { (surroundingLocations) in
                print(surroundingLocations.count, "this is the count of surrounding locations")
                self.locationDict.removeAll()
                for searchLocation in surroundingLocations {
                    self.locationDict.updateValue(searchLocation, forKey: searchLocation.address)
                    print(searchLocation.name!, "named!!")
                    if searchLocation == surroundingLocations.last {
                        self.mapView.addAnnotations(self.locationDict.compactMap(){ $0.1 }  )
                        self.mapView.showAnnotations(self.locationDict.compactMap(){ $0.1 }, animated: false)
                        self.searchController.dismiss(animated: true
                            , completion: {
                                print("dismissed")
                        })
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
                }
            }
        }
    }
    
    func queryAllLocations() {
        let query = PFQuery(className: "Location")
        //query.whereKey("coordinate", nearGeoPoint: PFGeoPoint(latitude: self.mapView.userLocation.coordinate.latitude, longitude: self.mapView.userLocation.coordinate.longitude) , withinMiles: 10.0)
        query.whereKey("subscribers", contains: PFUser.current()?.objectId!)
        getItems(query: query, firstTime: false)
    }
    
    func queryAndFollowNearyby() {
        print("querying nearby", self.currentLocation)
        //Come back - get the items and populate
        let query = PFQuery(className: "Location")
        query.limit = 3
        let userLocationGp = PFGeoPoint(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
        query.whereKey("coordinate", nearGeoPoint: userLocationGp, withinMiles: 30.0)
        query.whereKey("status", equalTo: "Registered")
        getItems(query: query, firstTime: true)
    }
        
    func getItems(query:PFQuery<PFObject>, firstTime: Bool) {
        Location().getLocations(query: query, completion: { (locationObjects) in
            DataModel.locations = locationObjects
            if firstTime {
                var locationsAsPFObject = [PFObject]()
                for l in locationObjects {
                    print("object:", l.name!)
                    l.isCurrentUserSubscribed = true
                    let locationObject = PFObject(withoutDataWithClassName: "Location", objectId: l.objectId)
                    locationObject.add(PFUser.current()!.objectId!, forKey: "subscribers")
                    locationsAsPFObject.append(locationObject)
                    if l.objectId == locationObjects.last!.objectId {
                        print("object Id's are equal try to save")
                        PFObject.saveAll(inBackground: locationsAsPFObject, block: { (success, error) in
                            if error == nil {
                                print("Success: Saved nearby locations")
                            }
                        })
                    }
                }
            }
            self.locationDict.removeAll()
            if let locations = DataModel.locations {
                var ids = [String]()
                for location in locations {
                    if firstTime {
                        location.isCurrentUserSubscribed = true
                    }
                    self.locationDict.updateValue(location, forKey: location.address)
                    //if location.isCurrentUserSubscribed {
                        ids.append(location.objectId)
                    //}
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
                                        if let image = object["image"] as? PFFileObject {
                                            image.getDataInBackground {
                                                (imageData:Data?, error:Error?) -> Void in
                                                if error == nil  {
                                                    if let finalimage = UIImage(data: imageData!) {
                                                        if object["itemPrice"] != nil {
                                                            //Put into sqlite
                                                           let newItem = Item(object: object, image: finalimage)
                                                            self.locationDict[object.objectId!]?.items.append(newItem)
                                                            DataModel.items.append(newItem)
                                                            if DataModel.items.count == objects.count {
                                                                DataModel.createItemsPerLocationDict()
                                                                self.mapView.addAnnotations(self.locationDict.compactMap(){ $0.1 }  )
                                                                self.mapView.showAnnotations(self.locationDict.compactMap(){ $0.1 }, animated: true)
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
                }
            }
        })
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if mapView.selectedAnnotations[0] is MKUserLocation == false {
            self.selectedLocation = view.annotation as? Location
            self.performSegue(withIdentifier: "showPlaces", sender: nil)
        }
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
        } else {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        if let location = annotation as? Location {
            print("found a registered ")
            if (DataModel.locations?.contains(location))! && location.registrationStatus == "Requested" {
                annotationView.markerTintColor = UIColor.lightGray
            } else if (DataModel.getSubscribedLocations().contains(location)) || self.firstTimeUser {
                annotationView.markerTintColor = UIColor(red: 0, green: 51/255, blue: 102/255, alpha: 1)
            } else if (DataModel.locations?.contains(location))!  {
                annotationView.markerTintColor = UIColor(red: 135.0/255.0, green: 206.0/255.0, blue: 235.0/255.0, alpha: 1.0)
            }
            annotationView.canShowCallout = true
            let infoButton = Sender(type: .infoLight)
            annotationView.rightCalloutAccessoryView = infoButton
            infoButton.buttonIdentifier = location.subtitle
            infoButton.addTarget(self, action: #selector(MapVC.showLocation(sender:)), for: UIControlEvents.touchUpInside)
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
            let navController = segue.destination as! UINavigationController
            let target = navController.topViewController as! FilterCategoriesVC
            target.mapToNewItemCategory = self.mapToNewItemCategory
            target.mapToFilterItemCategory = self.mapToFilterItemCategory
            
        } else if segue.identifier == "showItemFeedVC" {
            let targetVC = segue.destination as! ItemFeedVC
            targetVC.selectedLocation = self.selectedLocation
            targetVC.fromMap = true
        } else if segue.identifier == "showPlaces" {
            let targetVC = segue.destination as! PlacesVC
            if self.chosenFilter == "" {
                if let shownLocations = DataModel.locations {
                    print("these are the locations i am passing")
                    print(shownLocations[0].items, shownLocations[0].items.count)
                    targetVC.locations = shownLocations
                    targetVC.selectedLocationIndex = shownLocations.firstIndex(of: selectedLocation)!
                }
            } else {
                let selectedAnnotation = mapView.selectedAnnotations[0] as! Location
                let annotationLocations = mapView.annotations as! [Location]
                targetVC.selectedLocationIndex = annotationLocations.firstIndex(of: selectedAnnotation)!
                targetVC.locations = annotationLocations
            }
            targetVC.fromMap = true
            
        }
    }
    
    
    @IBAction func collectionViewButton(_ sender: Any) {
        self.mapToFilterItemCategory = true
        performSegue(withIdentifier: "toCollectionView", sender: self)
    }
}

class Sender: UIButton {
    var buttonIdentifier: String?
}




