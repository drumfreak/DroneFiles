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
    
    @IBOutlet var mySplitView: NSSplitView!
    @IBOutlet var leftView: NSSplitViewItem!
    @IBOutlet var rightView: NSSplitViewItem!
    @IBOutlet weak var splitViewRightController: SplitViewRightViewController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mySplitView.adjustSubviews();
        // self.appDelegate.videoSplitViewController = self
        
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = self.appSettings.appViewBackgroundColor.cgColor
        
        
    }
    
}
