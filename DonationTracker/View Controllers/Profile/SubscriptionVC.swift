//
//  SubscriptionVC.swift
//  DonationTracker
//
//  Created by Gabe Wilson on 12/24/18.
//  Copyright © 2018 Gabe Wilson. All rights reserved.
//

import Foundation
import UIKit
import Parse

class SubscriptionVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var subscriptions = [String]()
    var newTag = String()
    
    @IBAction func subscriptionUnwind(segue: UIStoryboardSegue) {
        if segue.identifier == "subscriptionUnwind" {
            subscriptions.insert(newTag, at: 0)
            self.tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        if let follows = PFInstallation.current()?.channels {
            subscriptions = follows
        }
        print("In Subscription")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showAddVC))
    }
    
    @objc func showAddVC() {
        self.performSegue(withIdentifier: "showAdd", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subscriptions.count
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let remove = UITableViewRowAction(style: .destructive, title: "Remove") { action, index in
            print("more button tapped")
            self.removeTag(index: index.row)
        }
        remove.backgroundColor = UIColor.red
        return [remove]
    }
    
    func removeTag(index: Int) {
        PFInstallation.current()?.remove(subscriptions[index], forKey: "channels")
        subscriptions.remove(at: index)
        tableView.reloadData()
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        cell.textLabel?.text = subscriptions[indexPath.row]
        cell.textLabel?.textColor = UIColor(red: 0, green: 51/255, blue: 102/255, alpha: 1)
        let priceLabel = UILabel(frame: .zero)
        priceLabel.text = "Price Label"
        priceLabel.textColor = UIColor.lightGray
        priceLabel.sizeToFit()
        cell.accessoryView = priceLabel
        return cell
    }
    
    
    
}
