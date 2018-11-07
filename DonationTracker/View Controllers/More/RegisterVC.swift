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
import MapKit

class RegisterVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchBarDelegate, UITextFieldDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendButtonOutlet: UIBarButtonItem!
    
    @IBAction func sendAction(_ sender: Any) {
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
                        }
                    }
                }
            }
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
    
    //Location Fields
    var recommendedLocations = [Location]()
    var locationSelected = false
    var selectedLocation = Location()

    override func viewDidLoad() {
        setupUI()
    }
    
    func setupUI() {
        setupSearchBar()
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
        headers[1] = "Domain"
        items[1][0] = "Work Email i.e. '@goodwill.org'"
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
            self.items[1][0] = String(describing: locationItem.url)
            //filter url to get email substring before .com or .org
            //locationItem.url?.absoluteString
            locationItem.placemark
            self.locationSelected = true
            self.tableView.reloadData()
        }
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
                    self.items[1][0] = location.admin.username!
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
        print("count of rows")
        return items[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = items[indexPath.section][indexPath.row]
        cell.selectionStyle = .none
        if selectedLocation.address != "" && selectedLocation.name != "" && indexPath.section == 2 {
            cell.selectionStyle = .gray
        }
        if locationSelected && (indexPath.section != 2 || enteredCode != "") {
            cell.textLabel?.textColor = UIColor.black
        } else {
            cell.textLabel?.textColor = UIColor.lightGray
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sectionTitle = headers[section] as? String {
            return sectionTitle
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 && indexPath.row == 0 && enteredCode == "" {
            var customMessage = ""
            if selectedLocation.address == "" && selectedLocation.name == "" {
                customMessage = "You must choose a location before you can be sent a verification code."
                let verificationAlert = UIAlertController(title: "Notice", message: customMessage, preferredStyle: UIAlertControllerStyle.alert)
                //textField.p
                verificationAlert.addAction(UIAlertAction(title: "Done", style: .default, handler: { (action: UIAlertAction!) in
                }))
                present(verificationAlert, animated: true, completion: nil)
            } else {
                if selectedLocation.domain != nil {
                    customMessage = "Your work email must end in '\(String(describing: selectedLocation.domain!))' \nRemember to check your spam."
                } else {
                    customMessage = "Enter your work email"
                }
                let refreshAlert = UIAlertController(title: "Confirm Email", message: customMessage, preferredStyle: UIAlertControllerStyle.alert)
                refreshAlert.addTextField(configurationHandler: { (textField) in
                    textField.placeholder = "Enter your employee email"
                })
                refreshAlert.addAction(UIAlertAction(title: "Enter", style: .default, handler: { (action: UIAlertAction!) in
                    let emailTextField = refreshAlert.textFields![0]
                    if !(emailTextField.text?.isEmpty)! && self.isValidEmail(email: emailTextField.text!) {
                        let emailString = emailTextField.text!
                        if self.matchesBusinessEmailDomain(emailString: emailString) {
                            var code = self.createVerificationCode()
                            self.sendMail(email: emailString, code: code)
                            self.showEnterVerficationCodeAlertView(code: code)
                        } else {
                            print("Error: Domain does not match")
                        }
                    } else {
                        print("Error: Invalid email")
                    }
                }))
                refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                }))
                present(refreshAlert, animated: true, completion: nil)
            }
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
                self.data = response.mapItems.map { $0.name! }
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
    
    
    func sendMail(email: String, code: String) {
        if let path = Bundle.main.path(forResource: "keys", ofType: "plist") {
            let keys = NSDictionary(contentsOfFile: path)
            print(keys!["sendGridKey"] as! String)
        }
        let sendGrid = SendGrid(withAPIKey: "")
        let content = SGContent(type: .plain, value: "The verification code is \(code).")
        let from = SGAddress(email: "sender@donationtracker.com")
        let personalization = SGPersonalization(to: [ SGAddress(email: email) ])
        let subject = "Verification Code"
        let email = SendGridEmail(personalizations: [personalization], from: from, subject: subject, content: [content])
        
        sendGrid.send(email: email) { (response, error) in
            if let error = error {
                print(error)
            } else {
                print("Email Sent")
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
        //verificationAlert.actions[0].isEnabled = false or tf.addTarget(self, action: #selector(self.textChanged), for: .editingChanged)
        verificationAlert.textFields![0].tag = Int(code)!
        verificationAlert.textFields![0].addTarget(self, action: #selector(RegisterVC.textFieldDidChange(_:)), for: .editingChanged)
        verificationAlert.addAction(UIAlertAction(title: "Enter", style: .default, handler: { (action: UIAlertAction!) in
            //Change action to a func that returns boolean
            //1) true close
            //2) false change the message
            let textField = verificationAlert.textFields![0]
            if textField.text == code {
                print("SUCCESS: Entered the correct code!") //COMEBACK
                self.headers[2] = "Verified \u{2713}"
                self.items[2][0] = code
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
        let range = emailString.lastIndex(of: "@")!..<emailString.endIndex
        let paramDomain = String(emailString[range])
        if paramDomain == selectedLocation.domain {
            return true
        }
        return false
    }
    
    func matchVerificationCode(code: String, enteredText: String) -> Bool {
        return code == enteredText
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if !(textField.text?.isEmpty)! && Int(textField.text!) == textField.tag {
            enterAction.isEnabled = true
        }
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
}
