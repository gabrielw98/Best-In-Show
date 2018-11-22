//
//  AddItemDetails.swift
//  DonationTracker
//
//  Created by Gabe Wilson on 11/20/18.
//  Copyright © 2018 Gabe Wilson. All rights reserved.
//

import Foundation
import UIKit

class AddItemDetailsVC: UIViewController, UITextFieldDelegate {
    
    var placeHolders = ["Name", "Price", "Tags"]
    var programmaticTextField = UITextField()
    var buttonXMin: CGFloat = 0.0
    
    //Name, price, tags, category image
    
    @IBOutlet weak var toolBarBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var activityMonitor: UIActivityIndicatorView!
    
    @IBAction func addTagAction(_ sender: Any) {
        print("added tag", textField.text)
        DataModel.tags.append(textField.text!)
        let tagButton = UIButton()
        tagButton.setTitle(textField.text, for: .normal)
        tagButton.setTitleColor(UIColor(red: 173/255, green: 216/255, blue: 230/255, alpha: 1), for: .normal)
        tagButton.backgroundColor = UIColor(red: 0, green: 51/255, blue: 102/255, alpha: 1)
        tagButton.layer.masksToBounds = true
        tagButton.layer.cornerRadius = 10
        tagButton.sizeToFit()
        self.scrollView.addSubview(tagButton)
        tagButton.frame = CGRect(x: buttonXMin, y: self.view.frame.minY, width: tagButton.frame.width + 10, height: tagButton.frame.height)
        buttonXMin = tagButton.frame.maxX + 10
        print("scrollview hidden?", scrollView.isHidden)
        textField.text = ""
    }
    
    
    override func viewDidLoad() {
        textField.autocapitalizationType = .words
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        textField.becomeFirstResponder()
        self.buttonXMin = scrollView.frame.minX
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
    self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.topItem?.title = ""
        self.textField.placeholder = ""
        self.activityMonitor.isHidden = false
        activityMonitor.startAnimating()
        
    }
    
    var keyBoardHeight:CGFloat = 0.0
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) {
            self.navigationController?.navigationBar.topItem?.title = "Item " + DataModel.currentAddItemPage
            self.textField.placeholder = DataModel.currentAddItemPage
            self.configureTextField()
            self.textField.becomeFirstResponder()
            if self.toolBar.frame.maxY == self.view.frame.maxY {
                print("made it to change keyboard")
                self.toolBar.frame.origin.y -= self.keyBoardHeight
            }
            self.activityMonitor.stopAnimating()
            self.activityMonitor.isHidden = true
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        textField.resignFirstResponder()
        
    }
    
    
    
    func configureTextField() {
        if DataModel.currentAddItemPage == "Name" {
            textField.autocapitalizationType = .words
            textField.returnKeyType = .next
            self.scrollView.isHidden = true
            self.toolBar.isHidden = true
        } else if DataModel.currentAddItemPage == "Price" {
            textField.returnKeyType = .next
            textField.keyboardType = .numbersAndPunctuation
            self.scrollView.isHidden = true
            self.toolBar.isHidden = true
            
        } else if DataModel.currentAddItemPage == "Tags" {
            textField.returnKeyType = .next
            self.scrollView.isHidden = false
            self.toolBar.isHidden = false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .next {
            
        }
        return true
    }
    
    @objc func textFieldDidChange() {
        if let text = textField.text {
            if self.navigationController!.navigationBar.topItem!.title == "Item Name" {
                DataModel.name = text
            } else if self.navigationController!.navigationBar.topItem!.title == "Item Price" {
                DataModel.price = text
            } else if self.navigationController!.navigationBar.topItem!.title == "Item Tags" {
                
            }
        }
        
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let  char = string.cString(using: String.Encoding.utf8)!
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            var updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            if let title = self.navigationController!.navigationBar.topItem!.title {
                if title == "Item Tags" {
                    if (textField.text?.isEmpty)! {
                        updatedText = "#"
                        textField.text = updatedText
                    }
                    if updatedText.contains(" ") || !updatedText.contains("#") {
                        return false
                    }
                } else if title == "Item Price" { // get textfield that only allows number and period input
                    print("inside item price", (textField.text?.isEmpty)!)
                    if (textField.text?.isEmpty)! { //disable paste text
                        updatedText = "$"
                        textField.text = updatedText
                    }
                    if updatedText.contains(" ") || !updatedText.contains("$") {
                        return false
                    }
                }
            }
            
            
            //Come back implement change domain capability.
        }
        
        return true
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            print("in showing keyboard")
            keyBoardHeight = keyboardSize.height
            
        }
    }
    
}

