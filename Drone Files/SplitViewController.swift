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
    @IBOutlet var videoDetailsSplitView: NSSplitViewItem!

    @IBOutlet weak var splitViewRightController: SplitViewRightViewController!
    @IBOutlet weak var videoDetailsViewController: VideoDetailsViewController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.appDelegate.splitViewController = self
        
        self.leftView = self.splitViewItem(for: self.appDelegate.fileBrowserViewController)
        
        self.rightView = self.splitViewItem(for: self.appDelegate.rightPanelSplitViewController)

        self.view.wantsLayer = true
        
        self.view.layer?.backgroundColor = self.appSettings.appViewBackgroundColor.cgColor
        
        self.videoDetailsSplitView = NSSplitViewItem(viewController: self.appDelegate.videoDetailsViewController)
        
        self.leftView.holdingPriority = 300
        self.rightView.holdingPriority = 200

        self.videoDetailsSplitView.holdingPriority = 300
        
        self.videoDetailsSplitView.isCollapsed = true
        self.insertSplitViewItem(self.videoDetailsSplitView!, at: 0)
        self.leftView.isCollapsed = false

        self.splitView.adjustSubviews()

    }

    func toggleFileBrowser() {
        
        self.videoDetailsSplitView.holdingPriority = 300
        self.leftView.holdingPriority = 300
        self.rightView.holdingPriority = 200
        
        self.leftView.isCollapsed = !self.leftView.isCollapsed
        
        if(!self.videoDetailsSplitView.isCollapsed) {
             self.videoDetailsSplitView.isCollapsed = true
        }
       
        
        self.splitView.adjustSubviews()
        
    }
    
    func showVideoDetails() {

        // self.leftView = self.splitViewItem(for: self.appDelegate.fileBrowserViewController)
        
        self.videoDetailsSplitView.holdingPriority = 300
        self.leftView.holdingPriority = 300
        self.rightView.holdingPriority = 700

        self.leftView.isCollapsed = !self.leftView.isCollapsed
        self.videoDetailsSplitView.isCollapsed = !self.videoDetailsSplitView.isCollapsed

        self.splitView.adjustSubviews()
    }
    
    func goFullScreenWindow1() {
        let presOptions: NSApplicationPresentationOptions = ([.fullScreen,.autoHideMenuBar])
        /*These are all of the options for NSApplicationPresentationOptions
         .Default
         .AutoHideDock              |   /
         .AutoHideMenuBar           |   /
         .DisableForceQuit          |   /
         .DisableMenuBarTransparency|   /
         .FullScreen                |   /
         .HideDock                  |   /
         .HideMenuBar               |   /
         .DisableAppleMenu          |   /
         .DisableProcessSwitching   |   /
         .DisableSessionTermination |   /
         .DisableHideApplication    |   /
         .AutoHideToolbar
         .HideMenuBar               |   /
         .DisableAppleMenu          |   /
         .DisableProcessSwitching   |   /
         .DisableSessionTermination |   /
         .DisableHideApplication    |   /
         .AutoHideToolbar */
        
        let optionsDictionary = [NSFullScreenModeApplicationPresentationOptions :
            UInt64(presOptions.rawValue)]
        
        self.view.enterFullScreenMode(NSScreen.main()!, withOptions:optionsDictionary)
        
        // self.view.wantsLayer = true
    }

}
