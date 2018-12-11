//
//  EmployeesVC.swift
//  DonationTracker
//
//  Created by Gabe Wilson on 11/18/18.
//  Copyright © 2018 Gabe Wilson. All rights reserved.
//

import Foundation
import UIKit
import Parse

class EmployeesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var employees = [PFUser]()
    var requests = [PFUser]()
    var segmentedControl: CustomSegmentedControl!

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        queryRequests()
        createSegmentedControl()
    }

    func createSegmentedControl() {
        print("in create")
        segmentedControl = CustomSegmentedControl.init(frame: CGRect.init(x: 0, y: (self.navigationController?.navigationBar.frame.maxY)!, width: self.view.frame.width, height: 45))
        // segmentedControl
        segmentedControl.backgroundColor = UIColor(red: 173/255, green: 216/255, blue: 230/255, alpha: 1.0)
        segmentedControl.commaSeperatedButtonTitles = "Employees,Requested"
        segmentedControl.addTarget(self, action: #selector(EmployeesVC.onChangeOfSegment), for: .valueChanged)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.textColor = UIColor.darkGray
        segmentedControl.selectorTextColor = UIColor(red: 0, green: 51/255, blue: 102/255, alpha: 1)
        segmentedControl.isUnderLinerNeeded = true
        self.view.addSubview(segmentedControl)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = CGRect(x: tableView.frame.minX, y: tableView.frame.minY + segmentedControl.frame.height, width: tableView.frame.width, height: tableView.frame.height - segmentedControl.frame.height)
        tableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentedControl.selectedSegmentIndex == 0 {
            return employees.count //come back here
        } else if segmentedControl.selectedSegmentIndex == 1 {
            return requests.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        if segmentedControl.selectedSegmentIndex == 0 {
            cell.textLabel?.text = employees[indexPath.row].username
            let button = UIButton(type:.roundedRect)
            button.setTitle("\u{2713}", for: .normal)
            button.setTitleColor(.darkGray, for: .normal)
            button.sizeToFit()
            cell.accessoryView = button
        } else if segmentedControl.selectedSegmentIndex == 1 {
            cell.textLabel?.text = requests[indexPath.row].username
            let buttonsView = UIView()
            buttonsView.frame = CGRect(x: cell.frame.midX, y: cell.frame.minY, width: cell.frame.width/2, height: cell.frame.height)
            let acceptButton = UIButton(type:.roundedRect)
            acceptButton.setTitle("Accept", for: .normal)
            acceptButton.setTitleColor(.white, for: .normal)
            acceptButton.backgroundColor = UIColor(red: 0, green: 51/255, blue: 102/255, alpha: 1)
            acceptButton.sizeToFit()
            acceptButton.frame = CGRect(x: acceptButton.frame.minX, y: acceptButton.frame.minY, width: acceptButton.frame.width * 1.5, height: acceptButton.frame.height)
            acceptButton.frame = CGRect(x: acceptButton.frame.minX, y: (cell.frame.height - acceptButton.frame.height)/2, width: acceptButton.frame.width, height: acceptButton.frame.height)
            acceptButton.layer.masksToBounds = true
            acceptButton.layer.cornerRadius = 10
            acceptButton.alpha = 1.0
            acceptButton.tag = indexPath.row
            acceptButton.addTarget(self, action: #selector(EmployeesVC.acceptedUser(sender:)), for: .touchUpInside)
            buttonsView.addSubview(acceptButton)
            let declineButton = UIButton(type:.roundedRect)
            declineButton.frame = acceptButton.frame
            declineButton.backgroundColor = UIColor.darkGray
            declineButton.setTitleColor(.white, for: .normal)
            declineButton.setTitle("Decline", for: .normal)
            declineButton.addTarget(self, action: #selector(EmployeesVC.declineUser(sender:)), for: .touchUpInside)
            declineButton.frame = CGRect(x: declineButton.frame.minX + declineButton.frame.width * 1.2, y: declineButton.frame.minY, width: declineButton.frame.width, height: declineButton.frame.height)
            declineButton.layer.masksToBounds = true
            declineButton.layer.cornerRadius = 10
            declineButton.alpha = 0.5
            buttonsView.addSubview(declineButton)
            cell.accessoryView = buttonsView
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if segmentedControl.selectedSegmentIndex == 1 {
            return false
        } else {
            return true
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if segmentedControl.selectedSegmentIndex == 0 {
            if editingStyle == .delete {
                print("Deleted")
                removeEmployee(indexPath: indexPath)
                self.employees.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    func queryRequests() {
        let query = PFQuery(className: "EmployeeStatusRequest")
        query.includeKey("_User")
        query.whereKey("admin", equalTo: PFUser.current()!)
        query.findObjectsInBackground(block: { (objects, error) in
            if let error = error {
                print(error)
            } else if let objects = objects {
                if objects.isEmpty {
                    print("no objects")
                    //self.performSegue(withIdentifier: "showEmployees", sender: nil)
                } else {
                    for object in objects {
                        let user = object["employee"] as! PFUser
                        user.fetchInBackground(block: { (userObject, error) in
                            if let empStatus = userObject!["employeeStatus"] as? String {
                                print("emp status", empStatus, user)
                                if empStatus == "Requested" {
                                    self.requests.append(user)
                                } else if empStatus == "Registered" {
                                    self.employees.append(user)
                                }
                                if object == objects.last {
                                    print("reloading")
                                    self.tableView.reloadData()
                                }
                            }
                        })
                    }
                }
            }
        })
    }
    
    @objc func onChangeOfSegment() {
        tableView.reloadData()
    }
    
    @objc func acceptedUser(sender: UIButton) {
        PFCloud.callFunction(inBackground: "registerEmployee", withParameters: ["userId": requests[sender.tag].objectId!]) {
            (response, error) in
            if error == nil {
                // Do something with response
                print(response, "response")
                let push = PFPush()
                push.setMessage("You have been registered as an employee!")
                push.sendInBackground(block: { (success, error) in
                    print(success)
                })
            } else {
                // Handle with error
                print(error?.localizedDescription, "Cloud Code Push Error")
            }
        }
        segmentedControl.buttonTapped(button: segmentedControl.buttons[0])
        self.segmentedControl.selectedSegmentIndex = 0
        employees.insert(requests.remove(at: sender.tag), at: 0)
        tableView.reloadData()
    }
    
    @objc func declineUser(sender: UIButton) {
        PFCloud.callFunction(inBackground: "declineRequest", withParameters: ["userId": requests[sender.tag].objectId!]) {
            (response, error) in
            if error == nil {
                // Do something with response
                print(response, "response")
            } else {
                // Handle with error
                print(error?.localizedDescription, "Cloud Code Push Error")
            }
        }
        print("pressed decline user")
        requests.remove(at: sender.tag)
        tableView.reloadData()
    }
    
    func removeEmployee(indexPath: IndexPath) {
        PFCloud.callFunction(inBackground: "removeEmployee", withParameters: ["userId": employees[indexPath.row].objectId!]) {
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
    
}

