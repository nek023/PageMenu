//
//  UIViewController+PageMenu.swift
//  PageMenu
//
//  Created by Katsuma Tanaka on 2015/10/08.
//  Copyright © 2015 Katsuma Tanaka. All rights reserved.
//

import UIKit
import PageMenu

public extension UIViewController {
    
    var pageViewController: PageViewController? {
        var viewController = self.parentViewController
        
        while parentViewController != nil {
            if let pageViewController = viewController as? PageViewController {
                return pageViewController
            }
            
            viewController = viewController?.parentViewController
        }
        
        return nil
    }
    
    var pageMenuController: PageMenuController? {
        if let pageMenuController = pageViewController?.parentViewController as? PageMenuController {
            return pageMenuController
        }
        
        return nil
    }
    
    func showNextPageAnimated(animated: Bool) {
        if let pageMenuController = self.pageMenuController {
            let currentPageIndex = pageMenuController.currentPageIndex
            pageMenuController.showPageAtIndex(currentPageIndex + 1, animateMenu: animated, animatePage: animated)
        } else if let pageViewController = self.pageViewController {
            let currentPageIndex = pageViewController.currentPageIndex
            pageViewController.showPageAtIndex(currentPageIndex + 1, animated: animated)
        }
    }
    
    func showPreviousPageAnimated(animated: Bool) {
        if let pageMenuController = self.pageMenuController {
            let currentPageIndex = pageMenuController.currentPageIndex
            pageMenuController.showPageAtIndex(currentPageIndex - 1, animateMenu: animated, animatePage: animated)
        } else if let pageViewController = self.pageViewController {
            let currentPageIndex = pageViewController.currentPageIndex
            pageViewController.showPageAtIndex(currentPageIndex - 1, animated: animated)
        }
    }
    
}
