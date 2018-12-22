//
//  RegisterEmployeeVC.swift
//  DonationTracker
//
//  Created by Gabe Wilson on 10/31/18.
//  Copyright © 2018 Gabe Wilson. All rights reserved.
//

import Foundation
import UIKit
import Parse
import DropDown
import SendGrid_Swift
import YelpAPI
import MapKit

class RegisterVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchBarDelegate, UITextFieldDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendButtonOutlet: UIBarButtonItem!
    
    @IBAction func sendAction(_ sender: Any) {
        if identifier == "employee" {
            let Request = PFObject(className: "EmployeeStatusRequest")
            Request["employee"] = PFUser.current()
            Request["admin"] = selectedLocation.admin
            Request.saveInBackground { (success, error) in
                if success {
                    print("Successfully saved the request.")
                    self.performSegue(withIdentifier: "profileUnwindFromRegisterEmployee", sender: nil)
                    //TODO cloud code change current user
                    if let currentUser = PFUser.current() {
                        currentUser["employeeStatus"] = "Requested"
                        //currentUser.add("Requested", forKey: "employeeStatus")
                        currentUser.saveInBackground { (success, error) in
                            if let error = error {
                                print("Error saving the location for user: \(error.localizedDescription)")
                            } else if success {
                                print("Saved Employee status for user.")
                                DataModel.employeeStatus = "Requested"
                            }
                        }
                    }
                }
            }
        } else if identifier == "admin" {
            sendAdminRequestEmail()
            if let currentUser = PFUser.current() {
                currentUser["adminStatus"] = "Requested"
                currentUser.saveInBackground { (success, error) in
                    if let error = error {
                        print("Error saving the location for user: \(error.localizedDescription)")
                    } else if success {
                        print("Saved Employee status for user.")
                        DataModel.adminStatus = "Requested"
                        self.saveLocation()
                    }
                }
            }
        }
    }
    
    func saveLocation() {
        let location = PFObject(className: "Location")
        location["name"] = self.selectedLocation.name
        if switchView.isOn {
            location["domain"] = self.suggestedDomain
        } else {
            location["domain"] = "N/A"
        }
        location["admin"] = PFUser.current()!
        location["address"] = self.selectedLocation.address
        location["subscribers"] = [PFUser.current()?.objectId]
        location["coordinate"] = PFGeoPoint(latitude: self.selectedLocation.locationCoordinate.latitude, longitude: self.selectedLocation.locationCoordinate.longitude)
        location["status"] = "Requested"
        location["phone"] = self.selectedLocation.phone
        location["website"] = self.selectedLocation.website
        if self.queriedBusinessImage != UIImage(named: "DefaultLocation") {
            if let imageData = self.queriedBusinessImage.jpegData(.lowest) {
                let file = PFFile(name: "img.png", data: imageData)
                location["image"] = file
            }
        }
        location.saveInBackground { (success, error) in
            if success {
                print("Location Saved")
            }
        }
    }
    
    @IBAction func registerAdminEmployeeUnwind(segue: UIStoryboardSegue) {
        if segue.identifier == "registrationUnwindFromDomainChange" {
            if fromEditingPhoneNumber {
                fromEditingPhoneNumber = false
                items[2][0] = selectedLocation.phone!
                tableView.reloadData()
            } else {
                print("new domain", self.suggestedDomain)
                self.selectedLocation.domain = self.suggestedDomain
                items[1][1] = self.suggestedDomain
                tableView.reloadData()
            }
        } else if segue.identifier == "registrationUnwindFromImageChange" {
            fromEditingPhoneNumber = false
            tableView.reloadData()
        }
    }
    
    //Drop Down Fields
    var data: [String] = []
    var dataFiltered: [String] = []
    var dropButton = DropDown()
    
    //Map Fields
    let locationManager = CLLocationManager()
    var matchingItems:[MKMapItem] = []
    var currentLocation: CLLocation!
    
    //UI Fields
    var items = [["Name", "Address"], ["Manager"], ["Verification Code"]]
    var searchController: UISearchController!
    var enterAction = UIAlertAction()
    var enteredCode = ""
    var identifier = ""
    var headers = ["Location", "Store Admin", ""]
    var suggestedDomain = ""
    var correctSuggestedDomain = false
    var chosenEmail = ""
    var switchView = UISwitch(frame: .zero)
    var businessImageView = UIImageView(frame: .zero)
    
    
    //Location Fields
    var recommendedLocations = [Location]()
    var locationSelected = false
    var selectedLocation = Location()
    var queriedBusinessImage = UIImage()
    var yelpClient: YLPClient?
    var fromEditingPhoneNumber = false

    override func viewDidLoad() {
        setupUI()
    }
    
    func setupUI() {
        setupSearchBar()
        switchView.setOn(false, animated: true)
        switchView.isOn = false
        self.tableView.dataSource = self
        self.tableView.delegate = self
        if identifier == "admin" {
            configureAdminUI()
        } else if identifier == "employee" {
            configureEmployeeUI()
        }
        sendButtonOutlet.isEnabled = false
    }
    
    func configureAdminUI() {
        print(dropButton, "printing the button")
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        headers[1] = "Location Email"
        headers[2] = "Details"
        items = [["Name", "Address"], ["Restrict Employee Domain?", "Admin Email"], ["Phone Number"]]
        self.tableView.reloadData()
        dropButton.anchorView = searchController.searchBar
        dropButton.bottomOffset = CGPoint(x: 0, y:(dropButton.anchorView?.plainView.bounds.height)!)
        dropButton.backgroundColor = .white
        dropButton.textColor = .darkGray
        dropButton.direction = .bottom
        dropButton.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)") //Selected item: code at index: 0
            let locationItem = self.matchingItems[index]
            self.items[0][0] = locationItem.name!
            var addressString : String = ""
            let pm = locationItem.placemark
            if pm.subLocality != nil {
                addressString = addressString + pm.subLocality! + ", "
            }
            if pm.thoroughfare != nil {
                addressString = addressString + pm.thoroughfare! + ", "
            }
            if pm.locality != nil {
                addressString = addressString + pm.locality! + ", "
            }
            if pm.country != nil {
                addressString = addressString + pm.country! + ", "
            }
            if pm.postalCode != nil {
                addressString = addressString + pm.postalCode! + " "
            }
            self.items[0][1] = addressString
            let query = PFQuery(className: "Location")
            query.whereKey("address", equalTo: addressString)
            query.getFirstObjectInBackground { (object, error) in
                if object != nil {
                    print(object, "got this thing here!!!", object!["name"] as! String)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.showAlreadyExistsAlert()
                    }
                }
            }
            if locationItem.url != nil {
                //self.items[1][1] = String(describing: self.suggestDomain(url: locationItem.url!))
                self.suggestedDomain = String(describing: self.suggestDomain(url: locationItem.url!))
            }
            self.selectedLocation.phone = locationItem.phoneNumber
            self.selectedLocation.website = locationItem.url?.absoluteString
            self.selectedLocation.domain = self.suggestedDomain
            self.selectedLocation.name = locationItem.name
            self.selectedLocation.address = addressString
            let filteredPhone = "+" + self.selectedLocation.phone.onlyDigits()
            print(filteredPhone, "filtered phone number")
            self.selectedLocation.phone = filteredPhone
            self.items[2][0] = filteredPhone
            self.getLocationImage(phoneNumber: filteredPhone)
            self.selectedLocation.locationCoordinate  = PFGeoPoint(latitude: locationItem.placemark.coordinate.latitude, longitude: locationItem.placemark.coordinate.longitude)
            print(locationItem.url?.absoluteString, "this is the absolute string")
            self.locationSelected = true
            self.tableView.reloadData()
        }
    }
    
    func showAlreadyExistsAlert() {
        let alreadyExistsAlert = UIAlertController(title: "Notice", message: "The location you selected is already registered.", preferredStyle: UIAlertControllerStyle.alert)
        alreadyExistsAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action: UIAlertAction!) in
            print("Reset the tableview here.")
            self.performSegue(withIdentifier: "profileUnwindFromCancel", sender: nil)
        }))
        present(alreadyExistsAlert, animated: true, completion: nil)
    }
    
    
    func getLocationImage(phoneNumber: String) {
        if let path = Bundle.main.path(forResource: "keys", ofType: "plist") {
            let keys = NSDictionary(contentsOfFile: path)
            self.yelpClient = YLPClient.init(apiKey: keys!["yelpKey"] as! String)
            yelpClient?.business(withPhoneNumber: phoneNumber, completionHandler: { (results, error) in
                if error == nil {
                    print("Count of returned businesses from Yelp API call:", results?.businesses.count)
                    if let business = results?.businesses.first {
                        print("Top business: \(business.name), id: \(business.identifier)")
                        if let url = business.imageURL {
                            if let data = try? Data(contentsOf: url)
                            {
                                print("made it inside ")
                                let image: UIImage = UIImage(data: data)!
                                self.queriedBusinessImage = image
                                self.tableView.reloadData()
                                return
                            }
                        }
                    }
                } else {
                    print("Yelp Api Error:", error!)
                }
            })
        }
        print("Using default image")
        self.queriedBusinessImage = UIImage(named: "DefaultLocation")!
        tableView.reloadData()
    }
    
    var isRequired = false
    @objc func toggleRequireBusinessDomain() {
        if isRequired {
            switchView.setOn(false, animated: true)
            items[1].remove(at: 1)
            items[1][1] = "Admin Email"
            tableView.reloadData()
            isRequired = false
        } else {
            switchView.setOn(true, animated: true)
            items[1].insert("Verify Your Work Domain", at: 1)
            items[1][2] = "Work Email i.e. '@goodwill.org'"
            tableView.reloadData()
            isRequired = true
        }
        
    }
    
    func suggestDomain(url: URL) -> String {
        let urlString = String(describing: url)
        var domain = ""
        print("url string", urlString)
        if urlString.range(of:".com") != nil {
            print("exists")
            var startIndex: String.Index!
            if !urlString.contains("www") {
                startIndex = urlString.endIndex(of: "//")
            } else {
                startIndex = urlString.endIndex(of: "www.")
            }
            let endIndex = urlString.endIndex(of: ".com")
            domain = String(urlString[startIndex!..<endIndex!])
        } else if urlString.range(of:".org") != nil {
            var startIndex: String.Index!
            if !urlString.contains("www") {
                startIndex = urlString.endIndex(of: "//")
            } else {
                startIndex = urlString.endIndex(of: "www.")
            }
            let endIndex = urlString.endIndex(of: ".org")
            print(startIndex, "start index", endIndex, "endIndex")
            domain = String(urlString[startIndex!..<endIndex!])
        }
        print(domain, "this is the domain")
        return "@" + domain
    }
    
    func configureEmployeeUI() {
        queryPossibleLocations()
        dropButton.anchorView = searchController.searchBar
        dropButton.bottomOffset = CGPoint(x: 0, y:(dropButton.anchorView?.plainView.bounds.height)!)
        dropButton.backgroundColor = .white
        dropButton.textColor = .darkGray
        dropButton.direction = .bottom
        dropButton.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)") //Selected item: code at index: 0
            self.locationSelected = true
            for location in self.recommendedLocations {
                if location.name == item {
                    self.selectedLocation = location
                    self.items[0][0] = location.name
                    self.items[0][1] = location.address
                    //Come back reverse geocode the address to get coordinates...
                    if let admin = location.admin as? PFUser {
                        self.items[1][0] = admin.username!
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func queryPossibleLocations() {
        let query = PFQuery(className: "Location")
        query.limit = 100
        let locationRef = Location()
        locationRef.getLocations(query: query, completion: { (locationObjects) in
            print("adding ", locationObjects.count, "objects")
            self.recommendedLocations = locationObjects
            self.data = locationRef.getLocationNames(locationsToFilter: locationObjects)
            self.tableView.reloadData()
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        //cell.accessoryType = .detailButton
        cell.textLabel?.text = items[indexPath.section][indexPath.row]
        cell.selectionStyle = .none
        if self.identifier == "employee" {
            if locationSelected && (indexPath.section != 2 || enteredCode != "") {
                cell.textLabel?.textColor = UIColor.black
            } else {
                cell.textLabel?.textColor = UIColor.lightGray
            }
        } else if self.identifier == "admin" {
            //COMEBACK
            if cell.textLabel!.text == "Name" || cell.textLabel!.text == "Address" || cell.textLabel!.text == "Verify Your Work Domain" || cell.textLabel!.text == "Work Email i.e. '@goodwill.org'" || cell.textLabel!.text == "Business Domain i.e. '@goodwill.org'" || cell.textLabel!.text == "Admin Email" || cell.textLabel?.text == "Phone Number"   {
                cell.textLabel?.textColor = UIColor.lightGray
            }
            if cell.textLabel?.text == "Restrict Employee Domain?" {
                switchView.addTarget(self, action: #selector(self.toggleRequireBusinessDomain), for: .valueChanged)
                cell.accessoryView = switchView
                cell.textLabel?.textColor = UIColor.lightGray
            }
            if indexPath.section == 2 {
                let imageView = UIImageView(image: self.queriedBusinessImage)
                imageView.frame = CGRect(x: cell.frame.maxX - 60.0, y: cell.frame.minY + 5, width: 30.0, height: 30.0)
                imageView.contentMode = .scaleAspectFill
                cell.accessoryView = imageView
            }
            
            if locationSelected && indexPath.section == 0 {
                cell.textLabel?.textColor = UIColor.black
            }
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sectionTitle = headers[section] as? String {
            return sectionTitle
        }
        return ""
    }
    
    func didPresentSearchController(_ currentSearchController: UISearchController) {
        currentSearchController.delegate = self
        currentSearchController.searchBar.delegate = self
        currentSearchController.searchBar.becomeFirstResponder()
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        DispatchQueue.main.async {
            searchBar.becomeFirstResponder()
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var customMessage = ""
        print(selectedLocation.address, "this location was selected")
        if !locationSelected {
            customMessage = "You must choose a location before you can be sent a verification code."
            let verificationAlert = UIAlertController(title: "Notice", message: customMessage, preferredStyle: UIAlertControllerStyle.alert)
            verificationAlert.addAction(UIAlertAction(title: "Done", style: .default, handler: { (action: UIAlertAction!) in
                self.searchController.delegate = self
                self.searchController.isActive = true
                self.searchController.definesPresentationContext = true
                //programmatically open up the search controller
            }))
            present(verificationAlert, animated: true, completion: nil)
            return
        }
        print(items[indexPath.section][indexPath.row], "this is the title")
        if items[indexPath.section][indexPath.row] == "Verify Your Work Domain" {
            let customMessage = "The domain should match your employees' email addresses. \n\nIs '\(selectedLocation.domain!)' your domain?"
            let suggestDomainAlertView = UIAlertController(title: "Verify Email Domain", message: customMessage, preferredStyle: UIAlertControllerStyle.alert)
            suggestDomainAlertView.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
                //reload Location Email Cells
                self.suggestedDomain = ""
                self.performSegue(withIdentifier: "showChangeDomain", sender: nil)
                tableView.reloadData()
            }))
            suggestDomainAlertView.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                self.correctSuggestedDomain = true
                self.items[1][1] = self.suggestedDomain
                tableView.reloadData()
                self.self.showVerifyEmailAlertView()
            }))
            present(suggestDomainAlertView, animated: true, completion: nil)
        } else if items[indexPath.section][indexPath.row] == "Admin Email" {
            self.self.showVerifyEmailAlertView()
        } else if items[indexPath.section][indexPath.row] == self.suggestedDomain {
            self.fromEditingPhoneNumber = false
            self.performSegue(withIdentifier: "showChangeDomain", sender: nil)
        } else if indexPath.section == 2 {
            self.fromEditingPhoneNumber = true
            self.performSegue(withIdentifier: "showChangeDomain", sender: nil)
        } else if items[indexPath.section][indexPath.row] == "Restrict Employee Domain?" {
            print("inside here....", switchView.isOn)
            if !switchView.isOn {
                showRestrictDomainInfoAlertView()
            }
        }
        if items[indexPath.section][indexPath.row] == "Work Email i.e. '@goodwill.org'" {
            //Come back - change placeholder to show @YourDomain.com
             self.self.showVerifyEmailAlertView()
        }
    }
    
    func showRestrictDomainInfoAlertView() {
        let restrictDominaInfoAlert = UIAlertController(title: "Restrict Domain \u{24D8}", message: "By restricting the domain, you are requiring all employees who register to use their work email with the domain you provide.", preferredStyle: UIAlertControllerStyle.alert)
        restrictDominaInfoAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        restrictDominaInfoAlert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (action: UIAlertAction!) in
            self.toggleRequireBusinessDomain()
        }))
        
        present(restrictDominaInfoAlert, animated: true, completion: nil)
    }
    
    func showVerifyEmailAlertView() {
        var customMessage = ""
        if selectedLocation.domain != nil && switchView.isOn {
            customMessage = "Your work email must end in '\(String(describing: selectedLocation.domain!))' \nRemember to check your spam."
        } else {
            customMessage = self.identifier == "admin" ? "Enter an email address for you admin account" : "Enter your employee email"
        }
         let refreshAlert = UIAlertController(title: "Verify Email", message: customMessage, preferredStyle: UIAlertControllerStyle.alert)
        refreshAlert.addTextField(configurationHandler: { (textField) in
            let placeHolder = self.identifier == "admin" ? self.suggestedDomain : "Enter your employee email"
            if self.switchView.isOn {
                 textField.placeholder = placeHolder
            } else {
                textField.placeholder = "donationtracker@gmail.com"
            }
        })
        refreshAlert.textFields![0].delegate = self
        refreshAlert.textFields![0].addTarget(self, action: #selector(RegisterVC.textFieldDidChange(_:)), for: .editingChanged)
        refreshAlert.addAction(UIAlertAction(title: "Enter", style: .default, handler: { (action: UIAlertAction!) in
            let emailTextField = refreshAlert.textFields![0]
            if !(emailTextField.text?.isEmpty)! && self.isValidEmail(email: emailTextField.text!) {
                let emailString = emailTextField.text!
                if self.matchesBusinessEmailDomain(emailString: emailString) {
                    let code = self.createVerificationCode()
                    self.sendMail(enteredEmail: emailString, code: code)
                    self.showEnterVerficationCodeAlertView(code: code)
                } else {
                    print("Error: Domain does not match")
                }
            } else {
                print("Error: Invalid email")
            }
        }))
        refreshAlert.actions[0].isEnabled = false
        enterAction = refreshAlert.actions[0]
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        present(refreshAlert, animated: true, completion: nil)
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
                textfield.textColor = tableView.tintColor
                if let backgroundview = textfield.subviews.first {
                    
                    // Background color
                    backgroundview.backgroundColor = UIColor.white
                    
                    // Rounded corner
                    backgroundview.layer.cornerRadius = 10;
                    backgroundview.clipsToBounds = true;
                    
                }
            }
            
            if let navigationbar = self.navigationController?.navigationBar {
                navigationbar.barTintColor = tableView.tintColor
            }
            navigationItem.searchController = sc
            navigationItem.hidesSearchBarWhenScrolling = false
            self.searchController = navigationItem.searchController
            
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if identifier == "employee" {
            dataFiltered = searchText.isEmpty ? data : data.filter({ (data) -> Bool in
                data.range(of: searchText, options: .caseInsensitive) != nil
            })
        } else if identifier == "admin" {
            guard let searchBarText = searchController.searchBar.text else { return }
            print("this is the searchbar text", searchBarText)
            let request = MKLocalSearchRequest()
            request.naturalLanguageQuery = searchBarText
            if self.currentLocation != nil {
            request.region = MKCoordinateRegion(center: self.currentLocation.coordinate, span: MKCoordinateSpanMake(0.05, 0.05))
            }
            let search = MKLocalSearch(request: request)
            
            search.start { response, _ in
                guard let response = response else {
                    return
                }
                self.matchingItems = response.mapItems
                var mutableResponse: [MKMapItem] = response.mapItems
                mutableResponse = mutableResponse.filter({ (Business) -> Bool in
                    Business.name != nil && Business.placemark.subLocality != nil && Business.phoneNumber != nil
                })
                self.data = mutableResponse.map { $0.name! + ": " + $0.placemark.subLocality! }
                print(self.data, "this is the starting data")
                if searchText.isEmpty {
                    self.dropButton.reloadAllComponents()
                    self.dropButton.dataSource = [""]
                    self.dropButton.hide()
                } else {
                    self.dropButton.reloadAllComponents()
                    self.dropButton.dataSource = self.data
                    self.dropButton.show()
                }
            }
        }
        dropButton.dataSource = dataFiltered
        dropButton.show()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        for ob: UIView in ((searchBar.subviews[0] )).subviews {
            if let z = ob as? UIButton {
                let btn: UIButton = z
                btn.setTitleColor(UIColor.white, for: .normal)
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //show mapview with suggestions pins should have 'choose' callout which allows the user to select.
    }
    
    
    func sendMail(enteredEmail: String, code: String) {
        if let path = Bundle.main.path(forResource: "keys", ofType: "plist") {
            let keys = NSDictionary(contentsOfFile: path)
            let sendGrid = SendGrid(withAPIKey: keys!["sendGridKey"] as! String)
            let content = SGContent(type: .plain, value: "The verification code is \(code).")
            let from = SGAddress(email: "sender@donationtracker.com")
            let personalization = SGPersonalization(to: [ SGAddress(email: enteredEmail) ])
            let subject = "Verification Code"
            let email = SendGridEmail(personalizations: [personalization], from: from, subject: subject, content: [content])
            
            sendGrid.send(email: email) { (response, error) in
                if let error = error {
                    print(error)
                } else {
                    self.chosenEmail = enteredEmail
                    print("Email Sent with this code:", code)
                }
            }
        }
    }
    
    func sendAdminRequestEmail() {
        self.performSegue(withIdentifier: "profileUnwindFromRegisterAdmin", sender: nil)
        if let path = Bundle.main.path(forResource: "keys", ofType: "plist") {
            let keys = NSDictionary(contentsOfFile: path)
            let sendGrid = SendGrid(withAPIKey: keys!["sendGridKey"] as! String)
            let content = SGContent(type: .plain, value: "\(PFUser.current()?.username!) wants to become an admin. Here is my email: " + chosenEmail + " Here is the objectId \(PFUser.current()?.objectId!)")
            let from = SGAddress(email: "sender@donationtracker.com")
            let personalization = SGPersonalization(to: [ SGAddress(email: "gabewils4@gmail.com") ])
            let subject = "Admin Account Verifaction"
            let email = SendGridEmail(personalizations: [personalization], from: from, subject: subject, content: [content])
            
            sendGrid.send(email: email) { (response, error) in
                if let error = error {
                    print(error)
                } else {
                    
                }
            }
        }
    }
    
    func showEnterVerficationCodeAlertView(code: String) {
        let verificationAlert = UIAlertController(title: "Verification Code", message: "Enter the code that was sent to your email", preferredStyle: UIAlertControllerStyle.alert)
        //textField.p
        verificationAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        verificationAlert.addTextField(configurationHandler: { (textField) in
        })
        verificationAlert.textFields![0].tag = Int(code)!
        verificationAlert.textFields![0].addTarget(self, action: #selector(RegisterVC.textFieldDidChange(_:)), for: .editingChanged)
        verificationAlert.addAction(UIAlertAction(title: "Enter", style: .default, handler: { (action: UIAlertAction!) in
            //Change action to a func that returns boolean
            //1) true close
            //2) false change the message
            let textField = verificationAlert.textFields![0]
            if textField.text == code {
                print("SUCCESS: Entered the correct code!") //COMEBACK
                self.headers[1] = "Verified \u{2713}"
                if self.identifier == "employee" {
                    self.items[2][0] = code
                } else {
                    if self.switchView.isOn {
                        self.items[1][2] = self.chosenEmail
                        self.switchView.isEnabled = false
                    } else {
                        self.items[1][1] = self.chosenEmail
                        self.switchView.isEnabled = false
                    }
                    
                }
                self.enteredCode = code
                self.tableView.reloadData()
                self.sendButtonOutlet.isEnabled = true
            }
        }))
        enterAction = verificationAlert.actions[1]
        verificationAlert.actions[1].isEnabled = false
        present(verificationAlert, animated: true, completion: nil)
    }
    

    func createVerificationCode() -> String {
        let min: UInt32 = 100_000
        let max: UInt32 = 999_999
        let i = min + arc4random_uniform(max - min + 1)
        return String(i)
    }
    
    func isValidEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    func matchesBusinessEmailDomain(emailString: String) -> Bool {
        if self.identifier == "employee" {
            let range = emailString.lastIndex(of: "@")!..<emailString.endIndex
            let paramDomain = String(emailString[range])
            if paramDomain == selectedLocation.domain {
                return true
            }
        } else if self.identifier == "admin" {
            return true
        }
        return false
    }
    
    func matchVerificationCode(code: String, enteredText: String) -> Bool {
        return code == enteredText
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if identifier == "employee" {
            if !(textField.text?.isEmpty)! && Int(textField.text!) == textField.tag {
                enterAction.isEnabled = true
            }
        } else if identifier == "admin" {
            print("in the text did change")
            print("this is the tag", textField.tag)
             if textField.text!.range(of: self.suggestedDomain) == nil && textField.tag == 0 {
                if self.switchView.isOn {
                    textField.text = textField.text! + self.suggestedDomain
                    let newPosition = textField.beginningOfDocument
                    let oneAfter = textField.position(from: newPosition, offset: 1)
                    //textField.selectedTextRange = textField.textRange(from: newPosition, to: oneAfter!)
                    //textField.textRange(from: newPosition, to: oneAfter!)
                    textField.selectedTextRange = textField.textRange(from: oneAfter!, to: oneAfter!)
                }
                enterAction.isEnabled = true
             } else if textField.tag > 0 {
                if !(textField.text?.isEmpty)! && Int(textField.text!) == textField.tag {
                    enterAction.isEnabled = true
                }
            }
        }
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let  char = string.cString(using: String.Encoding.utf8)!
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            print("this is the updated text", updatedText)
            if updatedText == self.suggestedDomain {
                enterAction.isEnabled = false
            } else {
                enterAction.isEnabled = true
            }
            let lastCharacters = updatedText.suffix(self.suggestedDomain.characters.count)
            if self.identifier == "admin" && !(textField.text?.isEmpty)! && updatedText.range(of: self.suggestedDomain) == nil || updatedText.contains(" ") || (textField.text?.characters.count)! > lastCharacters.count && lastCharacters != self.suggestedDomain {
                print("made it into false", self.switchView.isOn)
                if self.switchView.isOn {
                    return false
                }
            }
            //Come back implement change domain capability.
        }
        
        return true
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.first != nil {
            print("location:: (location)", locations.first, "this is the current location")
            self.currentLocation = locations.first
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showChangeDomain" {
            let navController = segue.destination as! UINavigationController
            let target = navController.topViewController as! ChangeDomainVC
            target.editedDomain = self.suggestedDomain
            target.editedNumber = self.selectedLocation.phone
            target.isEditingPhone = self.fromEditingPhoneNumber
            target.businessImage = self.queriedBusinessImage
        }
    }
}
