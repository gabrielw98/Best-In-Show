//
//  ItemDetailsVC.swift
//  DonationTracker
//
//  Created by Gabe Wilson on 12/20/18.
//  Copyright © 2018 Gabe Wilson. All rights reserved.
//

import Foundation
import UIKit

class ItemDetailsVC: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tagsScrollView: UIScrollView!
    
    var name = ""
    var price = ""
    var image = UIImage()
    var tags = [String]()
    
    var buttonXMin: CGFloat = 0.0
    
    override func viewDidLoad() {
        print("In Details")
        setupUI()
    }
    
    func setupUI() {
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
