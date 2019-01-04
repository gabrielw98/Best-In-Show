//
//  SubscriptionVC.swift
//  DonationTracker
//
//  Created by Gabe Wilson on 12/23/18.
//  Copyright © 2018 Gabe Wilson. All rights reserved.
//

import Foundation
import UIKit
import Parse
import XXXRoundMenuButton

class RecommendationVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noItemsView: UIView!
    @IBOutlet weak var addOutlet: UIBarButtonItem!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var subscriptionsTableView: UITableView!
    
    @IBAction func addAction(_ sender: Any) {
        if let barButton = sender as? UIBarButtonItem {
            if barButton.image == UIImage(named: "Add") {
                barButton.image = UIImage(named: "Cancel")
                showNoItemsView()
            } else if barButton.image == UIImage(named: "Cancel") {
                barButton.image = UIImage(named: "Add")
                self.noItemsView.isHidden = true
                roundMenuButton.isHidden = true
            }
        }
        
    }
    
    var roundMenuButton = XXXRoundMenuButton()
    
    var items = [Item]()
    var currentTime = Date()
    
    var selectedItem = Item()
    var subscribedTags = [String]()
    
    override func viewDidLoad() {
        setupUI()
        showNoItemsView()
        refreshData()
    }
    
    func setupUI() {
        self.textField.delegate = self
        self.textField.tintColor = UIColor(red: 0, green: 51/255, blue: 102/255, alpha: 1)
        self.noItemsView.isHidden = true
        self.currentTime = Calendar.current.date(byAdding: .weekOfYear, value: -4, to: Date())!
        self.tableView.addSubview(self.refreshControl)
        tableView.separatorInset = UIEdgeInsetsMake(0, 3, 0, 11);
        tableView.dataSource = self
        tableView.delegate = self
        subscriptionsTableView.delegate = self
        subscriptionsTableView.dataSource = self
        subscriptionsTableView.tableFooterView = UIView()
        if let channels = PFInstallation.current()?.channels {
            subscribedTags = channels
            subscriptionsTableView.reloadData()
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        noItemsView.addGestureRecognizer(tap)
    }
    
    @objc func handleTap() {
        // handling code
        print("print tapped")
        textField.resignFirstResponder()
    }
    
    func showNoItemsView() {
        self.noItemsView.isHidden = false
        roundMenuButton.isHidden = false
        self.view.addSubview(roundMenuButton)
        roundMenuButton.frame = CGRect(x: self.view.frame.size.width/2 - 100, y: (self.view.frame.size.height - ((self.tabBarController?.tabBar.frame.height)! + 150)), width: 200, height: 200)
        roundMenuButton.mainColor = UIColor(red: 0, green: 51/255, blue: 102/255, alpha: 1)
        roundMenuButton.centerButtonSize = CGSize(width: 44, height: 44)
        roundMenuButton.tintColor = UIColor.white
        roundMenuButton.jumpOutButtonOnebyOne = true
        roundMenuButton.load(withIcons: [UIImage(named: "Shirts")!,UIImage(named: "Pants")!,UIImage(named: "Shoes")!], startDegree: Float(-Double.pi), layoutDegree: Float(Double.pi/2));
        roundMenuButton.buttonClickBlock =  {(idx:NSInteger)-> Void in
            print("%d", idx);
            self.performSegue(withIdentifier: "showCustomSizes", sender: nil)
        };
    }
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(RecommendationVC.handleRefresh(_:)),
                                 for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.lightGray
        return refreshControl
    }()
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        refreshData()
    }
    
    func refreshData() {
        if let followingTags = PFInstallation.current()?.channels {
            if followingTags.count > 0 {
                let locationIds: [String] = DataModel.getSubscribedLocations().map { $0.objectId }
                var queries = [PFQuery]()
                for tag in followingTags {
                    let query = PFQuery(className: "Item")
                    query.whereKey("createdAt", greaterThan: self.currentTime)
                    query.whereKey("tags", equalTo: tag)
                    query.whereKey("locationId", containedIn: locationIds)
                    queries.append(query)
                    print("tag:", tag, locationIds, locationIds.count)
                    if tag == followingTags.last {
                        print(queries.count, "query count!")
                        let mainQuery = PFQuery.orQuery(withSubqueries: queries)
                        Item().queryRecommendedItems(query: mainQuery, completion: { (items) in
                            self.items = items
                            self.tableView.reloadData()
                            print("Reloaded data")
                            self.currentTime = Date()
                        })
                        self.refreshControl.endRefreshing()
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedItem = items[indexPath.row]
        self.performSegue(withIdentifier: "showDetails", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("count of newsfeed", items.count)
        if tableView == self.tableView {
            return items.count
        } else if tableView == self.subscriptionsTableView {
            return subscribedTags.count
        }
        print("Error: Should not see this.")
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SubscriptionTableViewCell
            cell.selectionStyle = .none
            cell.priceLabel.text = items[indexPath.row].price
            cell.nameLabel.text = items[indexPath.row].name
            cell.itemImageView?.image = items[indexPath.row].image
            return cell
        } else if tableView == self.subscriptionsTableView {
            let cell = UITableViewCell()
            cell.selectionStyle = .none
            cell.textLabel?.text = subscribedTags[indexPath.row]
            if subscribedTags.count > 3 {
                if indexPath.row % 2 == 0 {
                    cell.backgroundColor = UIColor.lightText
                } else {
                    cell.backgroundColor = UIColor.groupTableViewBackground
                }
            }
            return cell
        }
        print("Error: Should not see this.")
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.tableView {
            return 420
        } else if tableView == self.subscriptionsTableView {
            return 45
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        if tableView == self.subscriptionsTableView {
            let remove = UITableViewRowAction(style: .destructive, title: "Remove") { action, index in
                self.removeTag(index: index.row)
            }
            remove.backgroundColor = UIColor.red
            return [remove]
        }
        return [UITableViewRowAction]()
    }
    
    func removeTag(index: Int) {
        print("index", index)
        subscribedTags.remove(at: index)
        subscriptionsTableView.reloadData()
        print(subscribedTags, "setting to this")
        PFInstallation.current()!.channels = subscribedTags
        PFInstallation.current()!.saveInBackground { (success, error) in
            if error == nil {
                print("Success: Removed the channel")
            }
        }
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("returning this is where i add the tag")
        let currentInstallation = PFInstallation.current()
        currentInstallation!.addUniqueObject(textField.text!, forKey: "channels")
        currentInstallation?.saveInBackground(block: { (success, error) in
            if error == nil {
                print("Successfully Saved Tag")
                textField.resignFirstResponder()
                self.subscribedTags.append(self.textField.text!)
                self.subscriptionsTableView.reloadData()
            } else {
                print("Error: Couldn't save the new tag")
            }
        })
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails" {
            let targetVC = segue.destination as! ItemDetailsVC
            targetVC.image = selectedItem.image
            targetVC.price = selectedItem.price
            targetVC.name = selectedItem.name
            targetVC.tags = selectedItem.tags
        }
    }
}
