//
//  ThirdViewController.swift
//  PageMenu
//
//  Created by Katsuma Tanaka on 2015/10/08.
//  Copyright © 2015 Katsuma Tanaka. All rights reserved.
//

import UIKit

class ThirdViewController: UIViewController {
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    // MARK: - Actions
    
    @IBAction func prev(sender: AnyObject) {
        showPreviousPageAnimated(true)
    }
    
}
