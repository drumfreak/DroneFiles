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
        self.appDelegate.splitViewController = self
        self.leftView = self.splitViewItem(for: self.appDelegate.fileBrowserViewController)
        self.rightView = self.splitViewItem(for: self.appDelegate.rightPanelSplitViewController)

            
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
