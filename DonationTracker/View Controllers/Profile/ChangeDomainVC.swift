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
    
    override func viewDidLoad() {
        textField.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "registrationUnwindFromDomainChange" {
            let destinationVC = segue.destination as! RegisterVC
            destinationVC.suggestedDomain = textField.text!
        }
    }
    
    func isValidDomain(text: String) -> Bool {
        return text.contains("@") && text.contains(".") && text.characters.count > 5 && text.characters.last != "."
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            var updatedText = text.replacingCharacters(in: textRange, with: string)
            if (textField.text?.isEmpty)! && updatedText != "@" {
                updatedText = "@"
                textField.text = updatedText
            }
            if updatedText.contains(" ") || !updatedText.contains("@") || updatedText.characters.first != "@" {
                return false
            }
            if isValidDomain(text: updatedText) {
                self.doneOutlet.isEnabled = true
            } else {
                self.doneOutlet.isEnabled = false
            }
        }
        
        return true
    }
    
}
