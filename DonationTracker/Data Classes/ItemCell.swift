//
//  ItemCell.swift
//  DonationTracker
//
//  Created by Gabe Wilson on 11/19/18.
//  Copyright © 2018 Gabe Wilson. All rights reserved.
//

import Foundation
import UIKit

class ItemCell: UICollectionViewCell, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceBackground: UILabel!
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override var isSelected: Bool {
        didSet {
            self.contentView.backgroundColor = isSelected ? UIColor.blue : UIColor.yellow
            self.imageView.alpha = isSelected ? 0.75 : 1.0
        }
    }
}
