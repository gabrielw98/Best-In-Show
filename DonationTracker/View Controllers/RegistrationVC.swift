//
//  ViewController.swift
//  DonationTracker
//
//  Created by Gabe Wilson on 9/29/18.
//  Copyright © 2018 Gabe Wilson. All rights reserved.
//

import UIKit
import Parse

class RegistrationVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var submitLoginSignUpOutlet: UIButton!
    @IBOutlet weak var loginSignUpOutlet: UIButton!
    @IBOutlet weak var toggleLoginSignUpOutlet: UIButton!
    
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordLabel: UILabel!
    @IBOutlet weak var confirmPasswordTextfield: UITextField!
    @IBOutlet weak var confirmPasswordLine: UILabel!
    
    @IBAction func submitLoginSignUpAction(_ sender: Any) {
        if confirmPasswordTextfield.isHidden { //Login
            login()
        } else { //Sign Up
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
            let query = PFQuery(className: "Location")
            print(PFUser.current()!.objectId!, "this is the pfuser id")
            query.whereKey("subscribers", contains: PFUser.current()!.objectId!)
                Location().getLocations(query: query, completion: { (locationObjects) in
                    print("adding ", locationObjects.count, "objects")
                    DataModel.locations = locationObjects
                    if let locations = DataModel.locations {
                        let query = PFQuery(className: "Item")
                        let ids = locations.compactMap(){ $0.objectId }
                        query.whereKey("locationId", containedIn: ids)
                        query.findObjectsInBackground(block: { (objects, error) in
                            if let error = error {
                                print(error)
                            } else if let objects = objects {
                                if objects.isEmpty {
                                    print("No Items Found")
                                    self.refreshCurrentUserData()
                                } else {
                                    for object : PFObject in objects {
                                        if let image = object["image"] as? PFFile {
                                            image.getDataInBackground {
                                                (imageData:Data?, error:Error?) -> Void in
                                                if error == nil  {
                                                    if let finalimage = UIImage(data: imageData!) {
                                                        if object["itemPrice"] != nil {
                                                            print("items found")
                                                            //Put into sqlite
                                                            DataModel.items.append(Item(object: object, image: finalimage))
                                                            if object == objects.last {
                                                                self.refreshCurrentUserData()
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
                })
        }
    }
    
    
    func refreshCurrentUserData() {
        let query = PFQuery(className: "_User")
        query.whereKey("objectId", equalTo: PFUser.current()?.objectId! as! String)
        print("query pfuser object id", PFUser.current()?.objectId! as! String)
        query.getFirstObjectInBackground { (object, error) in
            print(object, "object")
            if let user = object as? PFUser {
                print(user, "user")
                if let employeeStatus = user["employeeStatus"] as? String {
                    print("emp status set", employeeStatus)
                    DataModel.employeeStatus = employeeStatus
                }
                if let adminStatus = user["adminStatus"] as? String {
                    print("admin status set", adminStatus)
                    DataModel.adminStatus = adminStatus
                }
                self.performSegue(withIdentifier: "showMap", sender: nil)
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
                print("successfully signed up the user")
            }
            /*if let error = error {
                print(error.localizedDescription)
            } else if success {
                print("User has been signed up")
            }*/
        })
    }
    
    func login() {
        PFUser.logInWithUsername(inBackground: usernameTextField.text!, password: passwordTextField.text!, block: { (user, error) in
            if user != nil {
                // Yes, User Exists
                self.performSegue(withIdentifier: "showMap", sender: nil)
                self.usernameTextField.text = ""
                self.passwordTextField.text = ""
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
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


