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
    var videoSplitview: NSSplitViewItem!
    var imageEditorSplitView: NSSplitViewItem!
    var fileManagerSplitView: NSSplitViewItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.appDelegate.rightPanelSplitViewController = self
        
        self.view.wantsLayer = true
        
        self.view.layer?.backgroundColor = self.appSettings.appViewBackgroundColor.cgColor
        
        self.mediaBinSplitView = NSSplitViewItem.init(viewController: self.appDelegate.mediaBinCollectionView)
      
        self.addSplitViewItem(self.mediaBinSplitView)
        
        self.appDelegate.mediaBinCollectionView.reloadContents()
        
    
        self.videoSplitview =  self.splitViewItem(for: self.appDelegate.videoSplitViewController!)!
        
        self.fileManagerSplitView =  self.splitViewItem(for: self.appDelegate.fileManagerViewController!)!
        
        self.imageEditorSplitView =  self.splitViewItem(for: self.appDelegate.imageEditorSplitViewController!)!
        
        self.showVideoSplitView()
        self.splitView.adjustSubviews()
    }
    
    
    func showVideoSplitView() {
        if(self.appDelegate.appSettings.videoSplitViewIsOpen == false) {
            self.appDelegate.appSettings.videoSplitViewIsOpen = true
            self.fileManagerSplitView.isCollapsed = true
            self.imageEditorSplitView.isCollapsed = true
            self.videoSplitview.isCollapsed = false
            self.appDelegate.videoSplitViewController?.splitView.setPosition(CGFloat(464.0), ofDividerAt:0)
           // self.splitView.adjustSubviews()
        }
        self.appDelegate.appSettings.imageEditorSplitViewIsOpen = false
        self.appDelegate.appSettings.fileManagerSplitViewIsOpen = false
    }
    
    func showImageEditorSplitView() {
        
        if(self.appDelegate.appSettings.imageEditorSplitViewIsOpen == false) {
            self.appDelegate.appSettings.imageEditorSplitViewIsOpen = true
            self.fileManagerSplitView.isCollapsed = true
            self.imageEditorSplitView.isCollapsed = false
            self.videoSplitview.isCollapsed = true
            //self.splitView.setPosition(CGFloat(464), ofDividerAt:1)
            self.appDelegate.imageEditorSplitViewController?.splitView.setPosition(CGFloat(464.0), ofDividerAt:0)
           // self.splitView.adjustSubviews()
        }
        self.appDelegate.appSettings.videoSplitViewIsOpen = false
        self.appDelegate.appSettings.fileManagerSplitViewIsOpen = false

    }
    
    func showFileManagerSplitView() {
        if(self.appDelegate.appSettings.fileManagerSplitViewIsOpen == false) {
            self.appDelegate.appSettings.fileManagerSplitViewIsOpen = true
            
            self.appDelegate.appSettings.imageEditorSplitViewIsOpen = true
            self.fileManagerSplitView.isCollapsed = false
            self.imageEditorSplitView.isCollapsed = true
            self.videoSplitview.isCollapsed = true
           // self.splitView.adjustSubviews()
        }
        self.appDelegate.appSettings.videoSplitViewIsOpen = false
        self.appDelegate.appSettings.imageEditorSplitViewIsOpen = false
    }
}

