//
//  ImageEditorSplitViewController.swift
//  Drone Files
//
//  Created by Eric Rosebrock on 5/17/17.
//  Copyright © 2017 The Web Freaks, INC. All rights reserved.
//

import Foundation
import Cocoa

class ImageEditorSplitViewController: NSSplitViewController {
    // @IBOutlet weak var splitViewRightController: SplitViewRightViewController!
    @IBOutlet var imageEditorControlsSplitView: NSSplitViewItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.appDelegate.imageEditorSplitViewController = self
        
        self.view.wantsLayer = true
        
        self.view.layer?.backgroundColor = self.appSettings.appViewBackgroundColor.cgColor
        
        self.imageEditorControlsSplitView = NSSplitViewItem.init(viewController: self.appDelegate.imageEditorControlsController)
        
        self.imageEditorControlsSplitView.holdingPriority = 40
        

        
        self.addSplitViewItem(self.imageEditorControlsSplitView)
        
        self.splitView.adjustSubviews()
        

        // self.appDelegate.rightPanelSplitViewController?.splitView.adjustSubviews()
    }
    
}
