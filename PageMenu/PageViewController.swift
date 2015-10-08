//
//  PageViewController.swift
//  PageMenu
//
//  Created by Katsuma Tanaka on 2015/10/08.
//  Copyright © 2015 Katsuma Tanaka. All rights reserved.
//

import UIKit

public protocol PageViewControllerDataSource: NSObjectProtocol {
    
    func numberOfPagesInPageViewController(pageViewController: PageViewController) -> Int
    func pageViewController(pageViewController: PageViewController, viewControllerForPageAtIndex index: Int) -> UIViewController
    
}

public protocol PageViewControllerDelegate: NSObjectProtocol {
    
    func pageViewController(pageViewController: PageViewController, didMoveToPageAtIndex index: Int)
    
    func pageViewController(pageViewController: PageViewController, willLoadViewControllerForPageAtIndex index: Int)
    func pageViewController(pageViewController: PageViewController, didLoadViewControllerForPageAtIndex index: Int)
    
    func pageViewController(pageViewController: PageViewController, willUnloadViewControllerForPageAtIndex index: Int)
    func pageViewController(pageViewController: PageViewController, didUnloadViewControllerForPageAtIndex index: Int)
    
    func pageViewControllerDidScroll(pageViewController: PageViewController)
    
}

public class PageViewController: UIViewController, UIScrollViewDelegate {
    
    // MARK: - Properties
    
    @IBOutlet private(set) weak var scrollView: UIScrollView!
    
    private let containerView = UIView()
    private var viewControllers: [UIViewController?] = []
    
    internal private(set) var numberOfPages: Int = 0
    public private(set) var currentPageIndex: Int = 0
    
    public weak var dataSource: PageViewControllerDataSource?
    public weak var delegate: PageViewControllerDelegate?
    
    
    // MARK: - Initializers
    
    public static func pageViewController() -> PageViewController? {
        let bundle = NSBundle(forClass: PageViewController.self)
        let storyboard = UIStoryboard(name: "PageMenu", bundle: bundle)
        
        return storyboard.instantiateViewControllerWithIdentifier("PageViewController") as? PageViewController
    }
    
    
    // MARK: - View Lifecycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.scrollsToTop = false
        scrollView.addSubview(containerView)
        
        reloadData()
        
        // Delegate
        delegate?.pageViewController(self, didMoveToPageAtIndex: currentPageIndex)
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        containerView.frame = CGRect(
            x: 0,
            y: 0,
            width: CGRectGetWidth(scrollView.frame) * CGFloat(numberOfPages),
            height: CGRectGetHeight(scrollView.frame)
        )
        
        for index in 0..<numberOfPages {
            guard let viewController = viewControllers[index] else {
                continue
            }
            
            viewController.view.frame = CGRect(
                x: CGRectGetWidth(scrollView.frame) * CGFloat(index),
                y: 0,
                width: CGRectGetWidth(scrollView.frame),
                height: CGRectGetHeight(scrollView.frame)
            )
        }
        
        scrollView.contentSize = containerView.frame.size
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Unload all invisible pages
        unloadAllPagesButPageAtIndex(currentPageIndex)
    }
    
    
    // MARK: - Managing Pages
    
    public func loadPageAtIndex(index: Int) {
        guard 0 <= index && index < numberOfPages && !isPageAtIndexLoaded(index),
            let viewController = dataSource?.pageViewController(self, viewControllerForPageAtIndex: index) else {
                return
        }
        
        // Delegate
        delegate?.pageViewController(self, willLoadViewControllerForPageAtIndex: index)
        
        // Add as a child view controller
        addChildViewController(viewController)
        
        viewController.view.frame = CGRect(
                x: CGRectGetWidth(scrollView.frame) * CGFloat(index),
                y: 0,
                width: CGRectGetWidth(scrollView.frame),
                height: CGRectGetHeight(scrollView.frame)
        )
        viewController.view.autoresizingMask = [.FlexibleRightMargin, .FlexibleHeight]
        containerView.addSubview(viewController.view)
        
        viewController.didMoveToParentViewController(self)
        
        // Set to array
        viewControllers[index] = viewController
        
        // Delegate
        delegate?.pageViewController(self, didLoadViewControllerForPageAtIndex: index)
    }
    
    public func unloadPageAtIndex(index: Int) {
        guard 0 <= index && index < numberOfPages && isPageAtIndexLoaded(index),
            let viewController = viewControllers[index] else {
                return
        }
        
        // Delegate
        delegate?.pageViewController(self, willUnloadViewControllerForPageAtIndex: index)
        
        // Remove from array
        viewControllers[index] = nil
        
        // Remove view controller
        viewController.willMoveToParentViewController(nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
        
        // Delegate
        delegate?.pageViewController(self, didUnloadViewControllerForPageAtIndex: index)
    }
    
    public func unloadAllPages() {
        for index in 0..<numberOfPages {
            unloadPageAtIndex(index)
        }
    }
    
    public func unloadAllPagesButPageAtIndex(index: Int) {
        for i in 0..<numberOfPages {
            if i != index {
                unloadPageAtIndex(i)
            }
        }
    }
    
    public func isPageAtIndexLoaded(index: Int) -> Bool {
        guard 0 <= index && index < numberOfPages else {
            return false
        }
        
        return (viewControllers[index] != nil)
    }
    
    public func showPageAtIndex(index: Int, animated: Bool) {
        guard 0 <= index && index < numberOfPages else {
            return
        }
        
        let contentOffset = CGRectGetWidth(scrollView.frame) * CGFloat(index)
        scrollView.setContentOffset(CGPoint(x: contentOffset, y: 0), animated: animated)
    }
    
    public func reloadData() {
        unloadAllPages()
        
        guard let dataSource = self.dataSource else {
            return
        }
        
        // Get number of pages
        numberOfPages = dataSource.numberOfPagesInPageViewController(self)
        
        guard numberOfPages > 0 else {
            return
        }
        
        // Resize container view
        containerView.frame = CGRect(
            x: 0,
            y: 0,
            width: CGRectGetWidth(scrollView.frame) * CGFloat(numberOfPages),
            height: CGRectGetHeight(scrollView.frame)
        )
        
        // Load page
        viewControllers = Array(count: numberOfPages, repeatedValue: nil)
        let newPageIndex = min(currentPageIndex, numberOfPages)
        loadPageAtIndex(newPageIndex)
        didMoveToPageAtIndex(newPageIndex)
    }
    
    
    // MARK: - UIScrollViewDelegate
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset
        let leftPageIndex = Int(contentOffset.x / CGRectGetWidth(scrollView.frame))
        
        guard 0 <= leftPageIndex && leftPageIndex < numberOfPages else {
            return
        }
        
        let leftPageOffset = CGRectGetWidth(scrollView.frame) * CGFloat(leftPageIndex)
        let rightPageIndex = (contentOffset.x > leftPageOffset) ? (leftPageIndex + 1) : leftPageIndex
        
        // Load pages if necessary
        loadPageAtIndex(leftPageIndex)
        loadPageAtIndex(rightPageIndex)
        
        // Delegate
        delegate?.pageViewControllerDidScroll(self)
    }
    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset
        let index = Int(contentOffset.x / CGRectGetWidth(scrollView.frame))
        
        didMoveToPageAtIndex(index)
    }
    
    public func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset
        let index = Int(contentOffset.x / CGRectGetWidth(scrollView.frame))
        
        didMoveToPageAtIndex(index)
    }
    
    private func didMoveToPageAtIndex(index: Int) {
        if currentPageIndex != index {
            currentPageIndex = index
            
            // Delegate
            delegate?.pageViewController(self, didMoveToPageAtIndex: index)
        }
    }
    
}
