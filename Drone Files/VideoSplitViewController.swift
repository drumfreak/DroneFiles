//
//  SplitViewController.swift
//  Drone Files
//
//  Created by Eric Rosebrock on 4/23/17.
//  Copyright © 2017 The Web Freaks, INC. All rights reserved.
//

import Foundation
import Cocoa

class VideoSplitViewController: NSSplitViewController {
    @IBOutlet var videoControlsSplitView: NSSplitViewItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.appDelegate.videoSplitViewController = self
     
        self.view.wantsLayer = true
   
        self.view.layer?.backgroundColor = self.appSettings.appViewBackgroundColor.cgColor
        
        self.videoControlsSplitView = NSSplitViewItem.init(viewController: self.appDelegate.videoControlsController)
    
        self.videoControlsSplitView.holdingPriority = 10

        self.splitView.setPosition(CGFloat(464.0), ofDividerAt: 0)
        
        self.addSplitViewItem(self.videoControlsSplitView)
        
        self.splitView.adjustSubviews()
    
        //self.appDelegate.rightPanelSplitViewController?.splitView.adjustSubviews()
    }
}
