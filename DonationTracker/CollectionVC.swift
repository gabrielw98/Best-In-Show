//
//  CollectionVC.swift
//  DonationTracker
//
//  Created by David Gabrielyan on 15/11/18.
//  Copyright © 2018 Gabe Wilson. All rights reserved.
//

import UIKit
import Foundation

class CollectionVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    let array = ["Shoes", "Clothes", "Hats", "Households", "Electronics", "Sports", "Toys", "Books", "Others"];
    var selectedFilter = ""
    
    @IBOutlet weak var collectionLayoutOutlet: UICollectionView!
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return array.count
    }
    
    //Populate the cell with an image
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCellVC
        let imageName = array[indexPath.row] + ".png"
        cell.CellImageOutlet.image = UIImage(named: imageName)
        
        let labelName = array[indexPath.row]
        cell.CellLabelOutlet.text = labelName
        cell.CellLabelOutlet.adjustsFontSizeToFitWidth = true
        return cell
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let itemWidth = UIScreen.main.bounds.width/4 - 10
        let itemHeight = UIScreen.main.bounds.height/8
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 60, left: 30, bottom: 10, right: 30) // redundant
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        
        layout.minimumLineSpacing = 35
        layout.minimumInteritemSpacing = 20
        
        collectionLayoutOutlet.collectionViewLayout = layout
        
        let screenSize: CGRect = UIScreen.main.bounds
        
        //
        //let doneItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: nil, action: #selector(done))
        //navItem.rightBarButtonItem = doneItem
        let myNav = UINavigationBar(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 44))
        let navItem = UINavigationItem(title: "Test")
        print(myNav.frame.height, "height")
        myNav.setItems([navItem], animated: false)
        myNav.translatesAutoresizingMaskIntoConstraints = true
        self.view.addSubview(myNav)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCellVC
        self.selectedFilter = cell.CellLabelOutlet.text!
        self.performSegue(withIdentifier: "mapUnwind", sender: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let targetVC = segue.destination as! MapVC
        targetVC.chosenFilter = self.selectedFilter
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
