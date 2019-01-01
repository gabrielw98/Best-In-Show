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

class RecommendationVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var roundMenu: XXXRoundMenuButton!
    @IBOutlet weak var noItemsView: UIView!
    
    @IBAction func addAction(_ sender: Any) {
        self.performSegue(withIdentifier: "showTags", sender: nil)
    }
    
    var roundMenuButton = XXXRoundMenuButton()
    
    var items = [Item]()
    var currentTime = Date()
    
    var selectedItem = Item()
    
    override func viewDidLoad() {
        self.noItemsView.isHidden = true
        print("In Subscription")
        self.currentTime = Calendar.current.date(byAdding: .weekOfYear, value: -4, to: Date())!
        self.tableView.addSubview(self.refreshControl)
        tableView.separatorInset = UIEdgeInsetsMake(0, 3, 0, 11);
        tableView.dataSource = self
        tableView.delegate = self
        
        showNoItemsView()
        refreshData()
    }
    
    func showNoItemsView() {
        self.noItemsView.isHidden = false
        let buttonMenu = XXXRoundMenuButton()
        self.view.addSubview(buttonMenu)
        buttonMenu.frame = CGRect(x: self.view.frame.size.width/2 - 100, y: (self.view.frame.size.height - ((self.tabBarController?.tabBar.frame.height)! + 150)), width: 200, height: 200)
        buttonMenu.mainColor = UIColor(red: 0, green: 51/255, blue: 102/255, alpha: 1)
        buttonMenu.centerButtonSize = CGSize(width: 44, height: 44)
        buttonMenu.tintColor = UIColor.white
        buttonMenu.jumpOutButtonOnebyOne = true
        buttonMenu.load(withIcons: [UIImage(named: "Items")!,UIImage(named: "Icon")!,UIImage(named: "ProfileIconSubscriptions")!], startDegree: Float(-Double.pi), layoutDegree: Float(Double.pi/2));
        buttonMenu.buttonClickBlock =  {(idx:NSInteger)-> Void in
            print("%d", idx);
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
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SubscriptionTableViewCell
        cell.selectionStyle = .none
        cell.priceLabel.text = items[indexPath.row].price
        cell.nameLabel.text = items[indexPath.row].name
        cell.itemImageView?.image = items[indexPath.row].image
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 420
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
