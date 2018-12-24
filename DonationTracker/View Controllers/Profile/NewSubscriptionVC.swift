//
//  NewSubscription.swift
//  DonationTracker
//
//  Created by Gabe Wilson on 12/23/18.
//  Copyright © 2018 Gabe Wilson. All rights reserved.
//

import Foundation
import UIKit
import Parse

class NewSubscriptionVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var textField: UITextField!
    
    @IBAction func saveAction(_ sender: Any) {
        let currentInstallation = PFInstallation.current()
        currentInstallation!.addUniqueObject(textField.text!, forKey: "channels")
        currentInstallation?.saveInBackground(block: { (success, error) in
            if error == nil {
                print("Successfully Saved Tag")
                self.newTag = self.textField.text!
                self.performSegue(withIdentifier: "subscriptionUnwind", sender: nil)
                
            }
        })
    }
    
    var newTag = String()
    
    
    override func viewDidLoad() {
        print("In New Subscription")
        textField.delegate = self
        textField.becomeFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            var updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)

                    if (textField.text?.isEmpty)! {
                        updatedText = "#"
                        textField.text = updatedText
                    }
            if updatedText.contains(" ") || !updatedText.contains("#") || updatedText.characters.first != "#" {
                        return false
                    }
            }
            return true
        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "subscriptionUnwind" {
            let target = segue.destination as! SubscriptionVC
            target.newTag = self.newTag
        }
    }
    
}
