//
//  AddItemVC.swift
//  DonationTracker
//
//  Created by Gabe Wilson on 11/20/18.
//  Copyright © 2018 Gabe Wilson. All rights reserved.
//

import Foundation
import UIKit

class AddItemVC: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    var pageControl = UIPageControl()
    var placeHolders = ["Name", "Price", "Tags", ""]
    var addItemIndex = 0
    
    @IBAction func cancelAction(_ sender: Any) {
        DataModel.currentAddItemPage = self.placeHolders[0]
        self.performSegue(withIdentifier: "mapUnwind", sender: nil)
    }
    
    
    lazy var orderedVCs: [UIViewController] = {
        return [self.newVC(viewController: "addDetail") as! AddItemDetailsVC, self.newVC(viewController: "addDetail") as! AddItemDetailsVC,self.newVC(viewController: "addDetail") as! AddItemDetailsVC, self.newVC(viewController: "imageCapture")]
    }()
    
    var currentIndex:Int {
        get {
            return orderedVCs.index(of: self.viewControllers!.first!)!
        }
        
        set {
            guard newValue >= 0,
                newValue < orderedVCs.count else {
                    return
            }
            
            let vc = orderedVCs[newValue]
            let direction:UIPageViewControllerNavigationDirection = newValue > currentIndex ? .forward : .reverse
            self.setViewControllers([vc], direction: direction, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        
        self.dataSource = self
        self.delegate = self
        // This sets up the first view that will show up on our page control
        if let firstViewController = orderedVCs.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
        configurePageControl()
    }
    
    func configurePageControl() {
        // The total number of pages that are available is based on how many available colors we have.
        pageControl = UIPageControl(frame: CGRect(x: 0,y: UIScreen.main.bounds.maxY - 50,width: UIScreen.main.bounds.width,height: 50))
        self.pageControl.numberOfPages = orderedVCs.count
        self.pageControl.currentPage = 0
        self.pageControl.tintColor = UIColor.black
        self.pageControl.pageIndicatorTintColor = UIColor.white
        self.pageControl.currentPageIndicatorTintColor = UIColor.black
        self.view.addSubview(pageControl)
        pageControl.isHidden = true
    }
    
    func newVC(viewController: String) -> UIViewController {
        
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: viewController)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedVCs.index(of: viewController) else {
            return nil
        }
        let previousIndex = currentIndex - 1
        // User is on the first view controller and swiped left to loop to
        // the last view controller.
        guard previousIndex >= 0 else {
            return nil
        }
        guard orderedVCs.count > previousIndex else {
            return nil
        }
        return orderedVCs[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = orderedVCs.index(of: viewController) else {
            return nil
        }
        print(viewControllerIndex, "this is the index!!")
        let nextIndex = currentIndex + 1
        let orderedViewControllersCount = orderedVCs.count
        // User is on the last view controller and swiped right to loop to
        // the first view controller.
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        return orderedVCs[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool)
    {
        if (!completed)
        {
            return
        }
        DataModel.currentAddItemPage = self.placeHolders[self.currentIndex]
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return orderedVCs.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return currentIndex
    }
    
    
    
}
