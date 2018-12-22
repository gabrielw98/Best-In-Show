//
//  ChangeDomainVC.swift
//  DonationTracker
//
//  Created by Gabe Wilson on 12/13/18.
//  Copyright © 2018 Gabe Wilson. All rights reserved.
//

import Foundation
import UIKit
import YelpAPI

class ChangeDomainVC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBAction func doneAction(_ sender: Any) {
        if !(textField.text?.isEmpty)! {
            self.performSegue(withIdentifier: "registrationUnwindFromDomainChange", sender: nil)
        } else {
            self.performSegue(withIdentifier: "registrationUnwindFromImageChange", sender: nil)
        }
    }
    @IBAction func infoAction(_ sender: Any) {
        //Come back
        // show a uiview (corner radius and dimmed background)
        //Describe what it means to have business domain.
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var doneOutlet: UIBarButtonItem!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var separatorLabel: UILabel!
    
    var editedNumber = ""
    var editedDomain = ""
    var isEditingPhone = false
    var businessImage = UIImage()
    var imagePicker = UIImagePickerController()
    var yelpClient: YLPClient?
    
    override func viewDidLoad() {
        textField.delegate = self
        if isEditingPhone {
            self.navigationItem.title = "New Phone Number"
            self.textField.keyboardType = .numberPad
            self.textField.placeholder = self.editedNumber
            self.textField.center.y = imageView.frame.minY - self.textField.frame.height
            self.separatorLabel.center.y = imageView.frame.minY - self.textField.frame.height
            self.separatorLabel.center.y = self.separatorLabel.center.y + separatorLabel.frame.height + textField.frame.height/2
            imageView.image = businessImage
            imageView.isUserInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imagePressed))
            imageView.addGestureRecognizer(tapGesture)
        } else {
            if editedDomain != "" {
                self.textField.text = editedDomain
            }
        }
        
        textField.becomeFirstResponder()
    }
    
    @objc func imagePressed() {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("in did dismiss")
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
        }
        doneOutlet.isEnabled = true
        picker.dismiss(animated: true, completion: nil);
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "registrationUnwindFromDomainChange" {
            let destinationVC = segue.destination as! RegisterVC
            if isEditingPhone {
                destinationVC.selectedLocation.phone = textField.text
                destinationVC.queriedBusinessImage = imageView.image!
            } else {
                destinationVC.suggestedDomain = textField.text!
            }
        } else if segue.identifier == "registrationUnwindFromImageChange" {
            let destinationVC = segue.destination as! RegisterVC
            destinationVC.queriedBusinessImage = imageView.image!
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
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                        self.getNewYelpBusinessImage()
                        self.doneOutlet.isEnabled = true
                    }
                    
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
    
    func getNewYelpBusinessImage() {
        if let path = Bundle.main.path(forResource: "keys", ofType: "plist") {
            let keys = NSDictionary(contentsOfFile: path)
            self.yelpClient = YLPClient.init(apiKey: keys!["yelpKey"] as! String)
            yelpClient?.business(withPhoneNumber: textField.text!, completionHandler: { (results, error) in
                if error == nil {
                    print("Count of returned businesses from Yelp API call:", results?.businesses.count)
                    if let business = results?.businesses.first {
                        print("Top business: \(business.name), id: \(business.identifier)")
                        if let url = business.imageURL {
                            if let data = try? Data(contentsOf: url)
                            {
                                print("made it inside ")
                                let image: UIImage = UIImage(data: data)!
                                DispatchQueue.main.async {
                                    let newImageAlertView = UIAlertController(title: "Notice", message: "DonationTracker has found a new business image for this phone number. \nWould you like to use it?", preferredStyle: UIAlertControllerStyle.alert)
                                    newImageAlertView.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
                                        print("canceled")
                                    }))
                                    newImageAlertView.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                                        self.imageView.image = image
                                    }))
                                    self.present(newImageAlertView, animated: true)
                                }
                                
                                return
                            }
                        }
                    }
                } else {
                    print("Yelp Api Error:", error!)
                }
            })
        }
    }
}
