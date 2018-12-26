//
//  ItemDetailsVC.swift
//  DonationTracker
//
//  Created by Gabe Wilson on 12/20/18.
//  Copyright © 2018 Gabe Wilson. All rights reserved.
//

import Foundation
import UIKit
import Parse

class ItemDetailsVC: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tagsScrollView: UIScrollView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var name = ""
    var price = ""
    var image = UIImage()
    var tags = [String]()
    
    var buttonXMin: CGFloat = 0.0
    
    override func viewDidLoad() {
        if DataModel.fromPush {
            //Come back
            self.nameLabel.isHidden = true
            self.priceLabel.isHidden = true
            self.activityIndicator.startAnimating()
            self.activityIndicator.isHidden = false
            //self.tabBarController?.tabBar.items![1] = UITabBarItem(title: "Items", image: UIImage(named: "Items")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal), selectedImage: UIImage(named: "Items"))
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelToMapView))
            populateFromPushObject()
        } else {
            setupUI()
        }
    }
    
    @objc func cancelToMapView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller1VC = storyboard.instantiateViewController(withIdentifier: "ItemFeedVC") as! ItemFeedVC
        let nav = UINavigationController(rootViewController: controller1VC)
        let rootVC = storyboard.instantiateViewController(withIdentifier: "TabBar") as! UITabBarController
        DataModel.fromPush = false
        DataModel.pushObjectId = ""
        rootVC.selectedIndex = 1
        rootVC.viewControllers![1] = nav
        let appDelegate = UIApplication.shared.delegate! as! AppDelegate
        appDelegate.window!.rootViewController = rootVC
    }
    
    override func awakeFromNib() {
        self.tabBarItem.title = "Items"
        self.tabBarItem.image = UIImage(named: "Items")
        
    }
    
    func populateFromPushObject() {
        let query = PFQuery(className: "Item")
        query.getObjectInBackground(withId: DataModel.pushObjectId) { (object, error) in
            if error == nil {
                if let image = object!["image"] as? PFFile {
                    image.getDataInBackground {
                        (imageData:Data?, error:Error?) -> Void in
                        if error == nil  {
                            if let finalimage = UIImage(data: imageData!) {
                                self.name = object!["name"] as! String
                                self.price = object!["itemPrice"] as! String
                                self.tags = object!["tags"] as! [String]
                                self.image = finalimage
                                self.setupUI()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func setupUI() {
        self.nameLabel.isHidden = false
        self.priceLabel.isHidden = false
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
        self.nameLabel.text = name
        self.imageView.image = image
        self.priceLabel.text = price
        addTagsToScrollView()
    }
    
    func addTagsToScrollView() {
        for tag in tags {
            let tagButton = UIButton()
            tagButton.setTitle(tag, for: .normal)
            tagButton.setTitleColor(UIColor(red: 173/255, green: 216/255, blue: 230/255, alpha: 1), for: .normal)
            tagButton.backgroundColor = UIColor(red: 0, green: 51/255, blue: 102/255, alpha: 1)
            tagButton.layer.masksToBounds = true
            tagButton.layer.cornerRadius = 10
            tagButton.sizeToFit()
            self.tagsScrollView.addSubview(tagButton)
            tagButton.frame = CGRect(x: buttonXMin, y: self.view.frame.minY, width: tagButton.frame.width + 10, height: tagButton.frame.height)
            buttonXMin = tagButton.frame.maxX + 10
        }
        
        self.tagsScrollView.center.x = self.view.frame.midX
    }
    
}
