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
    
    //Name, price, tags, category image
    
    @IBOutlet weak var textField: UITextField!
    
    
    override func viewDidLoad() {
        textField.autocapitalizationType = .words
        self.textField.delegate = self
        textField.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
       self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.topItem?.title = ""
        //self.navigationController?.navigationItem.leftBarButtonItem = nil
       
        //self.navigationItem.leftBarButtonItem = nil
        self.textField.placeholder = ""
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        print(textField.canBecomeFirstResponder)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) {
            self.navigationController?.navigationBar.topItem?.title = "Item " + DataModel.currentAddItemPage
            self.textField.placeholder = DataModel.currentAddItemPage
            self.configureTextField()
            self.textField.becomeFirstResponder()
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        textField.resignFirstResponder()
    }
    
    
    
    func configureTextField() {
        if DataModel.currentAddItemPage == "Name" {
            textField.autocapitalizationType = .words
            textField.returnKeyType = .next
        } else if DataModel.currentAddItemPage == "Price" {
            textField.returnKeyType = .next
            textField.keyboardType = .numbersAndPunctuation
        } else if DataModel.currentAddItemPage == "Tags" {
            textField.returnKeyType = .next
        }
    
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .next {
            
        }
        return true
    }
    
    
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    
    

    
    
    
    
    
}

