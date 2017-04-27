//
//  SplitViewController.swift
//  Drone Files
//
//  Created by Eric Rosebrock on 4/23/17.
//  Copyright © 2017 The Web Freaks, INC. All rights reserved.
//

import Cocoa

class SplitViewController: NSSplitViewController {

    @IBOutlet var mySplitView: NSSplitView!
    @IBOutlet var leftView: NSSplitViewItem!
    @IBOutlet var rightView: NSSplitViewItem!
    @IBOutlet weak var splitViewRightController: SplitViewRightViewController!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // print("Split View Loaded")
        
        mySplitView.adjustSubviews();
        self.splitViewRightController = self.childViewControllers[1] as! SplitViewRightViewController

        
        self.appDelegate.splitViewController = self
        
        
        
        /*
        
        */
        
    }
    
}
