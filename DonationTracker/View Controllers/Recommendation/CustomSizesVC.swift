//
//  CustomSizesVC.swift
//  DonationTracker
//
//  Created by Gabe Wilson on 1/3/19.
//  Copyright © 2019 Gabe Wilson. All rights reserved.
//

import Foundation
import UIKit
import Parse

class CustomSizesVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var updateOutlet: UIBarButtonItem!
    
    @IBAction func updateAction(_ sender: Any) {
        
        /*print("this would be the json")
        let jsonData = try! JSONSerialization.data(withJSONObject: customSizesMenDict)
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)
        print("json string", jsonString!)
        let newData = jsonString!.data(using: String.Encoding.utf8.rawValue)!
        let dictionary = try? JSONSerialization.jsonObject(with: newData, options: .mutableLeaves)
        print(dictionary)*/
        
        PFUser.current()!.setObject(DataModel.customSizes, forKey: "sizes")
        PFUser.current()?.saveInBackground(block: { (success, error) in
            if error == nil {
                print("Success: Saved the updated sizes")
            }
        })
    }
    
    
    var customClothing = ["Shirts", "Pants", "Shoes"]
    var customSizePlaceHolders = [["Size"], ["Length", "Width", "Style"], ["Size"]]
    var customSizesMen: [[[String]]] = [[["Small", "Medium", "Large", "XL", "XXL"]],[["28", "30", "32", "34", "36", "38"], ["28", "30", "32", "34", "36", "38"], ["Skinny Fit", "Slim Fit", "Original Fit", "Regular Fit", "Relaxed Fit",  "Loose Fit", "Slim Tapered"]],[["7","7.5","8","8.5","9","9.5","10","10.5","11","11.5","12","12.5","13"]]]
    var customSizesWomen = [["Small", "Medium", "Large", "XL", "XXL"],[["28", "30", "32", "34", "36", "38"], ["28", "30", "32", "34", "36", "38"], ["Skinny Fit", "Slim Fit", "Original Fit", "Regular Fit", "Relaxed Fit",  "Loose Fit", "Slim Tapered"]],["6","6.5","7","7.5","8","8.5","9","9.5","10","10.5","11"]]
    
    var customSizesMenDict = ["Shirts" : ["Small", "Medium", "Large", "XL", "XXL"], "Pants" : [["28", "30", "32", "34", "36", "38"], ["28", "30", "32", "34", "36", "38"], ["Skinny Fit", "Slim Fit", "Original Fit", "Regular Fit", "Relaxed Fit",  "Loose Fit", "Slim Tapered"]], "Shoes" : ["7","7.5","8","8.5","9","9.5","10","10.5","11","11.5","12","12.5","13"]]
    
    var selectedIndexPath = IndexPath()
    var chosenValue = ""
    
    override func viewDidLoad() {
        print("In Custom Sizes")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return customClothing.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (DataModel.sizes[customClothing[section]]?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        if let cellText = DataModel.customSizes[indexPath.row + indexPath.section] as? String {
            if cellText != "Size" && cellText != "Length" && cellText != "Width" && cellText != "Style" {
                cell.textLabel?.textColor = UIColor.black
            } else {
                cell.textLabel?.textColor = UIColor.lightGray
            }
            cell.textLabel?.text = DataModel.customSizes[indexPath.row + indexPath.section]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndexPath = indexPath
        let alertView = UIAlertController(
            title: "Select item from list",
            message: "\n\n\n\n\n\n\n\n\n",
            preferredStyle: .alert)
        let pickerView = UIPickerView(frame:
            CGRect(x: 0, y: 50, width: 260, height: 162))
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        
        alertView.view.addSubview(pickerView)
        let action = (UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
            DataModel.customSizes[indexPath.row + indexPath.section] = self.chosenValue
            print(DataModel.sizes, "data model sizes")
            tableView.reloadData()
        }))
        
        alertView.addAction(action)
        
        self.present(alertView, animated: false, completion: {
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
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return customSizesMen[selectedIndexPath.section][selectedIndexPath.row].count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return customSizesMen[selectedIndexPath.section][selectedIndexPath.row][row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        chosenValue = customSizesMen[selectedIndexPath.section][selectedIndexPath.row][row]
    }
    
}
