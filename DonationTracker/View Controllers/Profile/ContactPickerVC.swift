//
//  ContactPickerVC.swift
//  DonationTracker
//
//  Created by Gabe Wilson on 12/20/18.
//  Copyright © 2018 Gabe Wilson. All rights reserved.
//

import Foundation
import UIKit
import ContactsUI

class ContactPickerVC: UIViewController, CNContactPickerDelegate {
    
    override func viewDidLoad() {
        print("In contact picker")
        setupUI()
    }
    
    func setupUI() {
        let entityType = CNEntityType.contacts
        let authStatus = CNContactStore.authorizationStatus(for: entityType)
        if authStatus == CNAuthorizationStatus.notDetermined {
            let contactStore = CNContactStore.init()
            contactStore.requestAccess(for: entityType) { (success, error) in
                if error == nil {
                    self.openContacts()
                } else {
                    print("Error: Not authorized to see contacts.")
                }
            }
        } else if authStatus == CNAuthorizationStatus.authorized {
            self.openContacts()
        }
    }
    
    func openContacts() {
        let contactPicker = CNContactPickerViewController.init()
        contactPicker.delegate = self
    }
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        picker.dismiss(animated: true) {
            print("worked")
        }
    }
}
