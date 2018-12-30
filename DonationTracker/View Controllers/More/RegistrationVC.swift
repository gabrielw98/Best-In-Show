//
//  ViewController.swift
//  DonationTracker
//
//  Created by Gabe Wilson on 9/29/18.
//  Copyright © 2018 Gabe Wilson. All rights reserved.
//

import UIKit
import Parse
import UserNotifications

class RegistrationVC: UIViewController, UITextFieldDelegate, UNUserNotificationCenterDelegate {

    @IBOutlet weak var submitLoginSignUpOutlet: UIButton!
    @IBOutlet weak var loginSignUpOutlet: UIButton!
    @IBOutlet weak var toggleLoginSignUpOutlet: UIButton!
    
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordLabel: UILabel!
    @IBOutlet weak var confirmPasswordTextfield: UITextField!
    @IBOutlet weak var confirmPasswordLine: UILabel!
    
    @IBAction func submitLoginSignUpAction(_ sender: Any) {
        if confirmPasswordTextfield.isHidden {
            login()
        } else {
            signUp()
        }
    }
    
    @IBAction func registrationUnwind(segue: UIStoryboardSegue) {
    }
    
    @IBAction func toggleLoginSignUpAction(_ sender: Any) {
        let yourAttributes : [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.font : UIFont.systemFont(ofSize: 12),
            NSAttributedStringKey.foregroundColor : UIColor.white,
            NSAttributedStringKey.underlineStyle : NSUnderlineStyle.styleSingle.rawValue]
        if toggleLoginSignUpOutlet.titleLabel?.text == "Already have an account?" { //Change to login layout
            submitLoginSignUpOutlet.setTitle("Login", for: .normal)
            toggleLoginSignUpOutlet.setTitle(" Create a new account? ", for: .normal)
            let attributeString = NSMutableAttributedString(string: "Sign Up", attributes: yourAttributes)
            loginSignUpOutlet.setAttributedTitle(attributeString, for: .normal)
            confirmPasswordLabel.isHidden = true
            confirmPasswordTextfield.isHidden = true
            confirmPasswordLine.isHidden = true
            passwordTextField.returnKeyType = .go
        } else { //Change to Sign Up layout
            submitLoginSignUpOutlet.setTitle("Sign Up", for: .normal)
            toggleLoginSignUpOutlet.setTitle("Already have an account?", for: .normal)
            let attributeString = NSMutableAttributedString(string: "Login", attributes: yourAttributes)
            loginSignUpOutlet.setAttributedTitle(attributeString, for: .normal)
            confirmPasswordLabel.isHidden = false
            confirmPasswordTextfield.isHidden = false
            confirmPasswordLine.isHidden = false
            passwordTextField.returnKeyType = .next
        }
        textFieldDidChange()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if PFUser.current() != nil {
            self.refreshCurrentUserData()
        }
    }
    
    
    func refreshCurrentUserData() {
        print("here ans segue")
        let query = PFQuery(className: "_User")
        query.whereKey("objectId", equalTo: PFUser.current()?.objectId! as! String)
        print("query pfuser object id", PFUser.current()?.objectId! as! String)
        query.getFirstObjectInBackground { (object, error) in
            print(object, "object")
            if let user = object as? PFUser {
                print(user, "user")
                if let workPlace = user["locationId"] as? String {
                    DataModel.employeeWorkPlace = workPlace
                }
                if let employeeStatus = user["employeeStatus"] as? String {
                    print("emp status set", employeeStatus)
                    DataModel.employeeStatus = employeeStatus
                }
                if let adminStatus = user["adminStatus"] as? String {
                    print("admin status set", adminStatus)
                    DataModel.adminStatus = adminStatus
                }
                self.performSegue(withIdentifier: "showItemFeed", sender: nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        submitLoginSignUpOutlet.alpha = 0.5
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextfield.delegate = self
        usernameTextField.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        confirmPasswordTextfield.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        submitLoginSignUpOutlet.layer.cornerRadius = submitLoginSignUpOutlet.frame.height/2
    }
    
    func signUp() {
        let user = PFUser()
        user.username = usernameTextField.text
        user.password = passwordTextField.text
        user.signUpInBackground(block: { (success, error) in
            if success {
                self.performSegue(withIdentifier: "showMap", sender: nil)
                print("successfully signed up the user")
                self.createInstallationOnParse(deviceTokenData: DataModel.deviceToken)
            }
        })
    }
    
    func createInstallationOnParse(deviceTokenData:Data) {
        if let installation = PFInstallation.current(){
            installation.setDeviceTokenFrom(deviceTokenData)
            installation.setObject(PFUser.current()!, forKey: "user")
            installation.saveInBackground {
                (success: Bool, error: Error?) in
                if (success) {
                    print("You have successfully saved your push installation to Back4App!")
                } else {
                    if let myError = error{
                        print("Error saving parse installation \(myError.localizedDescription)")
                    }else{
                        print("Uknown error")
                    }
                }
            }
        }
    }
    
    func login() {
        PFUser.logInWithUsername(inBackground: usernameTextField.text!, password: passwordTextField.text!, block: { (user, error) in
            if user != nil {
                // Yes, User Exists
                self.usernameTextField.text = ""
                self.passwordTextField.text = ""
                self.refreshCurrentUserData()
                self.createInstallationOnParse(deviceTokenData: DataModel.deviceToken)
            } else {
                // No, User Doesn't Exist
            }
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        print("return pressed")
        if textField == self.usernameTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == self.passwordTextField {
            if confirmPasswordTextfield.isHidden {
                submitLoginSignUpAction(self)
            } else {
                confirmPasswordTextfield.becomeFirstResponder()
            }
        } else if textField == self.confirmPasswordTextfield {
            submitLoginSignUpAction(self)
        }
        return true
    }
    
    @objc func textFieldDidChange() {
        if !(usernameTextField.text?.isEmpty)! && !(passwordTextField.text?.isEmpty)!
            && (!(confirmPasswordTextfield.text?.isEmpty)! || confirmPasswordTextfield.isHidden) {
            submitLoginSignUpOutlet.alpha = 1.0
            submitLoginSignUpOutlet.isEnabled = true
        } else {
            submitLoginSignUpOutlet.alpha = 0.5
            submitLoginSignUpOutlet.isEnabled = false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMap" {
            let barViewControllers = segue.destination as! UITabBarController
            let nav = barViewControllers.viewControllers![0] as! UINavigationController
            let destinationViewController = nav.topViewController as! MapVC
            destinationViewController.firstTimeUser = true
        } else if segue.identifier == "showItemFeed" {
            let barViewControllers = segue.destination as! UITabBarController
            let nav = barViewControllers.viewControllers![0] as! UINavigationController
            let destinationViewController = nav.topViewController as! MapVC
            destinationViewController.showItemFeedVC = true
            print("showing item feed")
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
