//
//  PageMenuController.swift
//  PageMenu
//
//  Created by Katsuma Tanaka on 2015/10/08.
//  Copyright © 2015 Katsuma Tanaka. All rights reserved.
//

import UIKit

public protocol PageMenuControllerDataSource: PageViewControllerDataSource {
    
    func pageMenuController(pageMenuController: PageMenuController, menuItemForPageAtIndex index: Int) -> UIView
    
}

public class PageMenuController: UIViewController, PageViewControllerDataSource, PageViewControllerDelegate {
    
    // MARK: - Properties
    
    @IBOutlet private(set) weak var scrollView: UIScrollView!
    @IBOutlet private weak var scrollViewHeight: NSLayoutConstraint!
    
    private let containerView = UIView()
    private var menuItems: [UIView?] = []
    
    private var pageViewController: PageViewController {
        return childViewControllers.first as! PageViewController
    }
    
    private var numberOfPages: Int {
        return pageViewController.numberOfPages
    }
    
    public var currentPageIndex: Int {
        return pageViewController.currentPageIndex
    }
    
    public weak var delegate: PageViewControllerDelegate?
    public weak var dataSource: PageMenuControllerDataSource?
    
    
    // MARK: - Initializers
    
    public static func pageMenuController() -> PageMenuController? {
        let bundle = NSBundle(forClass: PageMenuController.self)
        let storyboard = UIStoryboard(name: "PageMenu", bundle: bundle)
        
        return storyboard.instantiateViewControllerWithIdentifier("PageMenuController") as? PageMenuController
    }
    
    
    // MARK: - View Lifecycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.scrollsToTop = false
        scrollView.addSubview(containerView)
        
        pageViewController.delegate = self
        pageViewController.dataSource = self
        
        reloadData()
    }
    
    
    // MARK: - Managing Menu Items
    
    public func loadPageAtIndex(index: Int) {
        pageViewController.loadPageAtIndex(index)
    }
    
    public func unloadPageAtIndex(index: Int) {
        pageViewController.unloadPageAtIndex(index)
    }
    
    public func unloadAllPages() {
        pageViewController.unloadAllPages()
    }
    
    public func unloadAllPagesButPageAtIndex(index: Int) {
        pageViewController.unloadAllPagesButPageAtIndex(index)
    }
    
    public func isPageAtIndexLoaded(index: Int) -> Bool {
        return pageViewController.isPageAtIndexLoaded(index)
    }
    
    private func centeredOffsetForMenuItemAtIndex(index: Int) -> CGFloat {
        guard 0 <= index && index < numberOfPages,
            let menuItem = menuItems[index] else {
                return 0
        }
        
        var offset = CGRectGetMinX(menuItem.frame) - (CGRectGetWidth(scrollView.frame) - CGRectGetWidth(menuItem.frame)) / 2
        offset = max(0, min(offset, scrollView.contentSize.width - CGRectGetWidth(scrollView.frame)))
        
        return offset
    }
    
    public func showPageAtIndex(index: Int, animateMenu: Bool, animatePage: Bool) {
        guard 0 <= index && index < numberOfPages else {
            return
        }
        
        let offset = centeredOffsetForMenuItemAtIndex(index)
        scrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: animateMenu)
        
        // Show the corresponding page
        pageViewController.showPageAtIndex(index, animated: animatePage)
    }
    
    public func reloadData() {
        // Remove all menu items
        for menuItem in menuItems {
            menuItem?.removeFromSuperview()
        }
        
        // Load pages
        pageViewController.reloadData()
        
        guard numberOfPages > 0,
            let dataSource = self.dataSource else {
                return
        }
        
        // Resize container view
        containerView.frame = CGRectZero
        
        // Load menu items
        menuItems = Array(count: numberOfPages, repeatedValue: nil)
        
        for index in 0..<numberOfPages {
            let menuItem = dataSource.pageMenuController(self, menuItemForPageAtIndex: index)
            menuItem.autoresizingMask = [.FlexibleRightMargin, .FlexibleHeight]
            menuItem.frame.origin = CGPoint(x: CGRectGetWidth(containerView.frame), y: 0)
            menuItems[index] = menuItem
            
            if index == 0 {
                containerView.frame.size.height = CGRectGetHeight(menuItem.frame)
            }
            
            containerView.frame.size.width += CGRectGetWidth(menuItem.frame)
            containerView.addSubview(menuItem)
        }
        
        scrollView.contentSize = containerView.frame.size
        let offset = CGPoint(x: CGRectGetWidth(scrollView.frame) * CGFloat(currentPageIndex), y: 0)
        scrollView.setContentOffset(offset, animated: false)
        
        // Update constraint
        scrollViewHeight.constant = CGRectGetHeight(containerView.frame)
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    
    // MARK: - PageViewControllerDataSource
    
    public func numberOfPagesInPageViewController(pageViewController: PageViewController) -> Int {
        guard let dataSource = self.dataSource else {
            return 0
        }
        
        return dataSource.numberOfPagesInPageViewController(pageViewController)
    }
    
    public func pageViewController(pageViewController: PageViewController, viewControllerForPageAtIndex index: Int) -> UIViewController {
        guard let dataSource = self.dataSource else {
            fatalError("Error: Data source must be set.")
        }
        
        return dataSource.pageViewController(pageViewController, viewControllerForPageAtIndex: index)
    }
    
    
    // MARK: - PageViewControllerDelegate
    
    public func pageViewController(pageViewController: PageViewController, didMoveToPageAtIndex index: Int) {
        delegate?.pageViewController(pageViewController, didMoveToPageAtIndex: index)
    }
    
    public func pageViewController(pageViewController: PageViewController, willLoadViewControllerForPageAtIndex index: Int) {
        delegate?.pageViewController(pageViewController, willLoadViewControllerForPageAtIndex: index)
    }
    
    public func pageViewController(pageViewController: PageViewController, didLoadViewControllerForPageAtIndex index: Int) {
        delegate?.pageViewController(pageViewController, didLoadViewControllerForPageAtIndex: index)
    }
    
    public func pageViewController(pageViewController: PageViewController, willUnloadViewControllerForPageAtIndex index: Int) {
        delegate?.pageViewController(pageViewController, willUnloadViewControllerForPageAtIndex: index)
    }
    
    public func pageViewController(pageViewController: PageViewController, didUnloadViewControllerForPageAtIndex index: Int) {
        delegate?.pageViewController(pageViewController, didUnloadViewControllerForPageAtIndex: index)
    }
    
    public func pageViewControllerDidScroll(pageViewController: PageViewController) {
        let scrollView = pageViewController.scrollView
        
        guard scrollView.dragging else {
            return
        }
        
        let contentOffset = scrollView.contentOffset
        let leftPageIndex = Int(contentOffset.x / CGRectGetWidth(scrollView.frame))
        
        guard 0 <= leftPageIndex && leftPageIndex < numberOfPages else {
            return
        }
        
        let leftPageOffset = CGRectGetWidth(scrollView.frame) * CGFloat(leftPageIndex)
        let rightPageIndex = (contentOffset.x > leftPageOffset) ? (leftPageIndex + 1) : leftPageIndex
        
        if leftPageIndex == rightPageIndex {
            let offset = centeredOffsetForMenuItemAtIndex(leftPageIndex)
            self.scrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: false)
        } else if rightPageIndex < numberOfPages {
            let rightPageOffset = CGRectGetWidth(view.frame) * CGFloat(rightPageIndex)
            let progress = (contentOffset.x - leftPageOffset) / (rightPageOffset - leftPageOffset)
            
            let leftPageCenteredOffset = centeredOffsetForMenuItemAtIndex(leftPageIndex)
            let rightPageCenteredOffset = centeredOffsetForMenuItemAtIndex(rightPageIndex)
            let offset = leftPageCenteredOffset + (rightPageCenteredOffset - leftPageCenteredOffset) * progress
            
            self.scrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: false)
        }
        
        delegate?.pageViewControllerDidScroll(pageViewController)
    }
    
}
