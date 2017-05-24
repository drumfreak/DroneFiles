//
//  FileManagerOptionsTabViewController.swift
//  Drone Files
//
//  Created by Eric Rosebrock on 4/25/17.
//  Copyright © 2017 The Web Freaks, INC. All rights reserved.
//
//import Foundation
import Cocoa
import AVKit
import AppKit
import AVFoundation
import Quartz

class FileManagerOptionsTabViewController: NSTabViewController {
    
    var fileSizes = NSMutableDictionary()
    
    var receivedFiles = NSMutableArray() {
        didSet {
            if (receivedFiles.count > 0) {
                self.appDelegate.fileManagerOptionsOrganizeController.receivedFiles = receivedFiles
                self.appDelegate.fileManagerOptionsCopyController.receivedFiles = receivedFiles
                self.appDelegate.fileManagerOptionsMoveController.receivedFiles = receivedFiles
                self.appDelegate.fileManagerOptionsRenameController.receivedFiles = receivedFiles
                self.appDelegate.fileManagerOptionsDeleteController.receivedFiles = receivedFiles
                
                self.fileSizes = (self.appDelegate.fileManagerViewController?.calculateFileSizesToDestination(fileUrls: self.receivedFiles as! Array<Any>))!
                
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = self.appSettings.appBackgroundColor.cgColor
 
        
        //  self.tabView.
        // print("FileManagerOptionsTabViewController loaded")
        
        self.appDelegate.fileManagerOptionsOrganizeController = self.childViewControllers[0] as! FileManagerOptionsOrganizeController
        
        self.appDelegate.fileManagerOptionsMoveController = self.childViewControllers[1] as! FileManagerOptionsMoveController
        
        self.appDelegate.fileManagerOptionsCopyController = self.childViewControllers[2] as! FileManagerOptionsCopyController
        
        self.appDelegate.fileManagerOptionsRenameController = self.childViewControllers[3] as! FileManagerOptionsRenameController
        
        self.appDelegate.fileManagerOptionsDeleteController = self.childViewControllers[4] as! FileManagerOptionsDeleteController
    }
    
}
