//
//  PageMenuDemoViewController.swift
//  PageMenu
//
//  Created by Katsuma Tanaka on 2015/10/08.
//  Copyright © 2015 Katsuma Tanaka. All rights reserved.
//

import UIKit
import PageMenu

class PageMenuDemoViewController: UIViewController, PageMenuControllerDataSource, PageViewControllerDelegate {

    // MARK: - Properties
    
    let viewControllerIdentifiers = [
        "FirstViewController",
        "SecondViewController",
        "ThirdViewController"
    ]
    
    let buttonBackgroundColors = [
        UIColor(red: 0.479616, green: 0.730191, blue: 0.227403, alpha: 1.0),
        UIColor(red: 0.117624, green: 0.503244, blue: 0.939561, alpha: 1.0),
        UIColor(red: 0.990757, green: 0.522628, blue: 0.0331616, alpha: 1.0)
    ]
    
    var contentViewController: PageMenuController? {
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
        
        let pageMenuController = PageMenuController.pageMenuController()!
        pageMenuController.dataSource = self
        pageMenuController.delegate = self
        
        self.contentViewController = pageMenuController
    }
    
    
    // MARK: - Actions
    
    func menuItemWasTapped(sender: UIButton) {
        contentViewController?.showPageAtIndex(sender.tag, animateMenu: true, animatePage: true)
    }
    
    
    // MARK: - PageMenuControllerDataSource
    
    func numberOfPagesInPageViewController(pageViewController: PageViewController) -> Int {
        return viewControllerIdentifiers.count
    }
    
    func pageViewController(pageViewController: PageViewController, viewControllerForPageAtIndex index: Int) -> UIViewController {
        return storyboard!.instantiateViewControllerWithIdentifier(viewControllerIdentifiers[index])
    }
    
    func pageMenuController(pageMenuController: PageMenuController, menuItemForPageAtIndex index: Int) -> UIView {
        let button = UIButton(type: .System)
        button.frame = CGRect(x: 0, y: 0, width: 200, height: 30)
        button.backgroundColor = buttonBackgroundColors[index];
        button.tag = index
        button.setTitle("Page \(index + 1)", forState: .Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.addTarget(self, action: "menuItemWasTapped:", forControlEvents: .TouchUpInside)
        
        return button
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
