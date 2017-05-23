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
   
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // self.view.wantsLayer = true
//        
//        self.appDelegate.splitViewController = self
//
//        // self.view.layer?.backgroundColor = self.appSettings.appBackgroundColor.cgColor
//
//        // self.view.layer?.backgroundColor = CGColor.black
//
//       // self.goFullScreenWindow1()
//    }
//    
    
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
    
//    override var representedObject: Any? {
//        didSet {
//            // Update the view, if already loaded.
//        }
//    }
    
//    override func awakeFromNib() {
////        if self.view.layer != nil {
////            let color : CGColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1.0)
////            self.view.layer?.backgroundColor = color
////        }
//        
//    }
    
}
