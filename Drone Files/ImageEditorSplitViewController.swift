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
    @IBOutlet var imageEditorControlsSplitViewItem: NSSplitViewItem!
    @IBOutlet var imageEditorSplitViewItem: NSSplitViewItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.appDelegate.imageEditorSplitViewController = self
        
        self.view.wantsLayer = true
        
        self.view.layer?.backgroundColor = self.appSettings.appViewBackgroundColor.cgColor
        
        self.imageEditorSplitViewItem = self.splitViewItem(for: self.appDelegate.imageEditorViewController!)
        
        self.imageEditorControlsSplitViewItem = NSSplitViewItem.init(viewController: self.appDelegate.imageEditorControlsController)
        
        self.imageEditorSplitViewItem.holdingPriority = 10

        self.imageEditorControlsSplitViewItem.holdingPriority = 30
        
        self.splitView.setPosition(CGFloat(434.0), ofDividerAt: 0)

        self.addSplitViewItem(self.imageEditorControlsSplitViewItem)
        
        self.splitView.adjustSubviews()
        

        // self.appDelegate.rightPanelSplitViewController?.splitView.adjustSubviews()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        //self.imageEditorSplitViewItem.holdingPriority = 10
        //self.imageEditorControlsSplitViewItem.holdingPriority = 10

        
        self.splitView.setPosition(CGFloat(434.0), ofDividerAt: 0)
        
        self.splitView.adjustSubviews()

    }
    
}
