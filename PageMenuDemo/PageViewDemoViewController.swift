//
//  PageViewDemoViewController.swift
//  PageMenu
//
//  Created by Katsuma Tanaka on 2015/10/08.
//  Copyright © 2015 Katsuma Tanaka. All rights reserved.
//

import UIKit
import PageMenu

class PageViewDemoViewController: UIViewController, PageViewControllerDataSource, PageViewControllerDelegate {
    
    // MARK: - Properties
    
    let viewControllerIdentifiers = [
        "FirstViewController",
        "SecondViewController",
        "ThirdViewController"
    ]
    
    var contentViewController: PageViewController? {
        willSet {
            if let contentViewController = self.contentViewController {
                contentViewController.willMoveToParentViewController(nil)
                contentViewController.view.removeFromSuperview()
                contentViewController.removeFromParentViewController()
            }
        }
        
        didSet {
            if let contentViewController = self.contentViewController {
                addChildViewController(contentViewController)
                
                let view = contentViewController.view
                view.frame = self.view.bounds
                view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
                self.view.addSubview(view)
                
                contentViewController.didMoveToParentViewController(self)
            }
        }
    }
    
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pageViewController = PageViewController.pageViewController()!
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        self.contentViewController = pageViewController
    }
    
    
    // MARK: - PageControllerDataSource
    
    func numberOfPagesInPageViewController(pageViewController: PageViewController) -> Int {
        return viewControllerIdentifiers.count
    }
    
    func pageViewController(pageViewController: PageViewController, viewControllerForPageAtIndex index: Int) -> UIViewController {
        return storyboard!.instantiateViewControllerWithIdentifier(viewControllerIdentifiers[index])
    }
    
    
    // MARK: - PageControllerDelegate
    
    func pageViewController(pageViewController: PageViewController, didMoveToPageAtIndex index: Int) {
        NSLog("*** pageViewController:didMoveToPageAtIndex:")
    }
    
    func pageViewController(pageViewController: PageViewController, willLoadViewControllerForPageAtIndex index: Int) {
        NSLog("*** pageViewController:willLoadViewControllerForPageAtIndex:")
    }
    
    func pageViewController(pageViewController: PageViewController, didLoadViewControllerForPageAtIndex index: Int) {
        NSLog("*** pageViewController:didLoadViewControllerForPageAtIndex:")
    }
    
    func pageViewController(pageViewController: PageViewController, willUnloadViewControllerForPageAtIndex index: Int) {
        NSLog("*** pageViewController:willUnloadViewControllerForPageAtIndex:")
    }
    
    func pageViewController(pageViewController: PageViewController, didUnloadViewControllerForPageAtIndex index: Int) {
        NSLog("*** pageViewController:didUnloadViewControllerForPageAtIndex:")
    }
    
    func pageViewControllerDidScroll(pageViewController: PageViewController) {
    }
    
}
