//
//  FileManagerSplitViewController.swift
//  Drone Files
//
//  Created by Eric Rosebrock on 5/24/17.
//  Copyright © 2017 The Web Freaks, INC. All rights reserved.
//

import Cocoa

class FileManagerSplitViewController: NSSplitViewController {
    
        @IBOutlet var mySplitView: NSSplitView!
        @IBOutlet var leftView: NSSplitViewItem!
        @IBOutlet var rightView: NSSplitViewItem!
        @IBOutlet weak var splitViewRightController: SplitViewRightViewController!
        
        
        override func viewDidLoad() {
            super.viewDidLoad()
            // self.appDelegate.videoSplitViewController = self
            
            //DispatchQueue.main.async {
            // mySplitView.adjustSubviews();
            
            self.view.wantsLayer = true
            self.view.layer?.backgroundColor = self.appSettings.appViewBackgroundColor.cgColor
            
            //}
        }
        
}
