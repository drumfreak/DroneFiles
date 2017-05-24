//
//  RightPanelSlitViewController.swift
//  Drone Files
//
//  Created by Eric Rosebrock on 5/23/17.
//  Copyright © 2017 The Web Freaks, INC. All rights reserved.
//


import Foundation
import Cocoa

class RightPanelSplitViewController: NSSplitViewController {
    
    @IBOutlet var mySplitView: NSSplitView!
    @IBOutlet var leftView: NSSplitViewItem!
    @IBOutlet var rightView: NSSplitViewItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // mySplitView.adjustSubviews();
        self.appDelegate.rightPanelSplitViewController = self
        //DispatchQueue.main.async {
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = self.appSettings.appViewBackgroundColor.cgColor
        //}
    }
    
}

