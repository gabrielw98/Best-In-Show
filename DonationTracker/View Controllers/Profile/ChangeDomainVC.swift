//
//  ChangeDomainVC.swift
//  DonationTracker
//
//  Created by Gabe Wilson on 12/13/18.
//  Copyright © 2018 Gabe Wilson. All rights reserved.
//

import Foundation
import UIKit

class ChangeDomainVC: UIViewController, UITextFieldDelegate {
    
    @IBAction func doneAction(_ sender: Any) {
        if !(textField.text?.isEmpty)! {
            self.performSegue(withIdentifier: "registrationUnwindFromDomainChange", sender: nil)
        }
    }
    @IBAction func infoAction(_ sender: Any) {
        //Come back
        // show a uiview (corner radius and dimmed background)
        //Describe what it means to have business domain.
    }
    
    @IBOutlet weak var doneOutlet: UIBarButtonItem!
    @IBOutlet weak var textField: UITextField!
    
    var editedNumber = ""
    var editedDomain = ""
    var isEditingPhone = false
    
    override func viewDidLoad() {
        textField.delegate = self
        if isEditingPhone {
            self.textField.keyboardType = .numberPad
            self.textField.placeholder = self.editedNumber
        } else {
            if editedDomain != "" {
                self.textField.text = editedDomain
            }
        }
        
        textField.becomeFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "registrationUnwindFromDomainChange" {
            let destinationVC = segue.destination as! RegisterVC
            if isEditingPhone {
                destinationVC.selectedLocation.phone = textField.text
            } else {
                destinationVC.suggestedDomain = textField.text!
            }
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        textField.resignFirstResponder()
    }
    
    func isValidDomain(text: String) -> Bool {
        return text.contains("@") && text.contains(".") && text.characters.count > 5 && text.characters.last != "."
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            var requiredText = self.isEditingPhone ? "+1" : "@"
            var updatedText = text.replacingCharacters(in: textRange, with: string)
            if (textField.text?.isEmpty)! && updatedText != requiredText {
                updatedText = requiredText
                textField.text = updatedText
            }
            if updatedText.contains(" ") || !updatedText.contains(requiredText) || updatedText[..<requiredText.endIndex] != requiredText {
                return false
            }
            if isEditingPhone {
                if updatedText.characters.count > 11 {
                    self.doneOutlet.isEnabled = true
                } else {
                    self.doneOutlet.isEnabled = false
                }
            } else {
                if isValidDomain(text: updatedText) {
                    self.doneOutlet.isEnabled = true
                } else {
                    self.doneOutlet.isEnabled = false
                }
            }
            
        }
        
        return true
    }
    
}
