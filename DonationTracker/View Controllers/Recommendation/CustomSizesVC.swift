//
//  CustomSizesVC.swift
//  DonationTracker
//
//  Created by Gabe Wilson on 1/3/19.
//  Copyright © 2019 Gabe Wilson. All rights reserved.
//

import Foundation
import UIKit

class CustomSizesVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var customClothing = ["Shirts", "Pants", "Shoes"]
    var customSizes = [["Size"], ["Length", "Width", "Style"], ["Size"]]
    
    override func viewDidLoad() {
        print("In Custom Sizes")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return customSizes.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return customSizes[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        cell.textLabel?.text = customSizes[indexPath.section][indexPath.row]
        cell.textLabel?.textColor = UIColor.lightGray
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        
        let alertView = UIAlertController(
            title: "Select item from list",
            message: "\n\n\n\n\n\n\n\n\n",
            preferredStyle: .alert)
        
        let pickerView = UIPickerView(frame:
            CGRect(x: 0, y: 50, width: 260, height: 162))
        pickerView.delegate = self
        pickerView.dataSource = self 
        // comment this line to use white color
        pickerView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        
        alertView.view.addSubview(pickerView)
        
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        
        alertView.addAction(action)
        
        self.present(alertView, animated: true, completion: {
            pickerView.frame.size.width = alertView.view.frame.size.width
        })
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UITableViewCell()
        header.textLabel!.text = customClothing[section]
        header.backgroundColor = UIColor(red: 135.0/255.0, green: 206.0/255.0, blue: 235.0/255.0, alpha: 1.0)
        header.textLabel?.textColor = self.navigationController?.navigationBar.barTintColor
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 20.0)
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 28
    }
    
    
}
