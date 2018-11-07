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
        DataModel.currentUserType = userType.admin
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
