//
//  MoreVC.swift
//  DonationTracker
//
//  Created by Gabe Wilson on 10/30/18.
//  Copyright © 2018 Gabe Wilson. All rights reserved.
//

import Foundation
import UIKit
import Parse

class MoreVC: UIViewController {

    @IBOutlet weak var employeeButtonOutlet: UIButton!
    
    @IBOutlet weak var adminButtonOutlet: UIButton!
    @IBAction func moreUnwind(segue: UIStoryboardSegue) {
    }
    
    @IBAction func registerBusinessAdmin(_ sender: Any) {
        self.performSegue(withIdentifier: "showRegisterAdmin", sender: nil)
    }
    
    
    @IBAction func registerBusinessEmployee(_ sender: Any) {
        if let button = sender as? UIButton {
            if button.titleLabel?.text == "Employee Status Pending" {
                let verificationAlert = UIAlertController(title: "Notice", message: "Your employee request is currently being reviewed.", preferredStyle: UIAlertControllerStyle.alert)
                //textField.p
                verificationAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action: UIAlertAction!) in
                }))
                present(verificationAlert, animated: true, completion: nil)
            } else if button.titleLabel?.text == "Register As A Business Employee" {
                self.performSegue(withIdentifier: "showRegisterEmployee", sender: nil)
            }
        }
    }
    
    @IBAction func registerAsABusinessAdminAction(_ sender: Any) {
        //send grid
        //email verification
        if let button = sender as? UIButton {
            if button.titleLabel?.text == "Admin Status Pending" {
                let verificationAlert = UIAlertController(title: "Notice", message: "Your employee request is currently being reviewed.", preferredStyle: UIAlertControllerStyle.alert)
                //textField.p
                verificationAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action: UIAlertAction!) in
                }))
                present(verificationAlert, animated: true, completion: nil)
            } else if button.titleLabel?.text == "Register As A Business Admin" {
                self.performSegue(withIdentifier: "showRegisterAdmin", sender: nil)
            }
        }
    }
    
    override func viewDidLoad() {
        setupButtonOutlets()
    }
    
    func setupButtonOutlets() {
        if DataModel.employeeStatus == "Requested" {
            employeeButtonOutlet.backgroundColor = employeeButtonOutlet.titleLabel?.textColor
            employeeButtonOutlet.setTitleColor(UIColor.white, for: .normal)
            employeeButtonOutlet.setTitle("Employee Status Pending", for: .normal)
            employeeButtonOutlet.layer.masksToBounds = true
            employeeButtonOutlet.layer.cornerRadius = 5.0
        } else if DataModel.employeeStatus == "Registered" {
            employeeButtonOutlet.backgroundColor = employeeButtonOutlet.titleLabel?.textColor
            employeeButtonOutlet.setTitleColor(UIColor.white, for: .normal)
            employeeButtonOutlet.setTitle("Employee Status Verified!", for: .normal)
            employeeButtonOutlet.backgroundColor = UIColor(red: 173/255, green: 216/255, blue: 230/255, alpha: 1.0)
            employeeButtonOutlet.layer.masksToBounds = true
            employeeButtonOutlet.layer.cornerRadius = 5.0
        }
        if DataModel.adminStatus == "Requested" {
            adminButtonOutlet.backgroundColor = adminButtonOutlet.titleLabel?.textColor
            adminButtonOutlet.setTitleColor(UIColor.white, for: .normal)
            adminButtonOutlet.setTitle("Admin Status Pending", for: .normal)
            adminButtonOutlet.layer.masksToBounds = true
            adminButtonOutlet.layer.cornerRadius = 5.0
        } else if DataModel.adminStatus == "Registered" {
            adminButtonOutlet.backgroundColor = adminButtonOutlet.titleLabel?.textColor
            adminButtonOutlet.setTitleColor(UIColor.white, for: .normal)
            adminButtonOutlet.backgroundColor = UIColor(red: 173/255, green: 216/255, blue: 30/255, alpha: 1.0)
            adminButtonOutlet.setTitle("Admin Status Verified!", for: .normal)
            adminButtonOutlet.layer.masksToBounds = true
            adminButtonOutlet.layer.cornerRadius = 5.0
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("made it here", segue.identifier)
        let navController = segue.destination as! UINavigationController
        let targetVC = navController.topViewController as! RegisterVC
        if segue.identifier == "showRegisterAdmin" {
            targetVC.identifier = "admin"
        } else if segue.identifier == "showRegisterEmployee" {
            targetVC.identifier = "employee"
        }
    }
    
    
    
}
