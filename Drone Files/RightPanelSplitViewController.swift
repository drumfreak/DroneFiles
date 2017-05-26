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

    @IBOutlet var mediaBinSplitView: NSSplitViewItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.appDelegate.rightPanelSplitViewController = self
        
        self.view.wantsLayer = true
        
        self.view.layer?.backgroundColor = self.appSettings.appViewBackgroundColor.cgColor
        
        self.mediaBinSplitView = NSSplitViewItem.init(viewController: self.appDelegate.mediaBinCollectionView)
      
        self.addSplitViewItem(self.mediaBinSplitView)
        
        self.appDelegate.mediaBinCollectionView.reloadContents()
        
        self.splitView.adjustSubviews()
    }
    
}

