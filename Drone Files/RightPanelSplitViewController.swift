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
    @IBOutlet var mediaBinSplitView: NSSplitViewItem!
    var mediaBinCollectionView: MediaBinCollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        print("1~~~~~~~~~~ This happened rightSplitView")
        
        
        self.appDelegate.rightPanelSplitViewController = self
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = self.appSettings.appViewBackgroundColor.cgColor
        
        self.mediaBinSplitView = NSSplitViewItem.init(viewController: self.appDelegate.mediaBinCollectionView)
        //let f2 = NSLayoutPriority.init(exactly: 300)
//
//        let f = NSLayoutPriority.init(exactly: 100)
//        
//        self.splitView.setHoldingPriority(f2!, forSubviewAt: 0)
//        
       
      
        self.addSplitViewItem(self.mediaBinSplitView)
        self.appDelegate.mediaBinCollectionView.reloadContents()
        // self.splitView.setHoldingPriority(f!, forSubviewAt: 1)
        self.splitView.adjustSubviews()
    }
    
}

