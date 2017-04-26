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
    
    @IBOutlet weak var fileBrowserViewController: FileBrowserViewController!
    
    @IBOutlet weak var fileManagerViewController: FileManagerViewController!
    
    @IBOutlet weak var fileManagerOptionsCopyController: FileManagerOptionsCopyController!
    
    @IBOutlet weak var fileManagerOptionsOrganizeController: FileManagerOptionsOrganizeController!
    
    @IBOutlet weak var fileManagerOptionsMoveController: FileManagerOptionsMoveController!
    
    @IBOutlet weak var fileManagerOptionsRenameController: FileManagerOptionsRenameController!
    
    @IBOutlet weak var fileManagerOptionsDeleteController: FileManagerOptionsDeleteController!
    
   // var receivedFiles = NSMutableArray()
    
    
    var receivedFiles = NSMutableArray() {
        didSet {
            if (receivedFiles.count > 0) {
                self.fileManagerOptionsOrganizeController.receivedFiles = receivedFiles
                self.fileManagerOptionsCopyController.receivedFiles = receivedFiles
                self.fileManagerOptionsMoveController.receivedFiles = receivedFiles
            }
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       //  self.tabView.
        print("FileManagerOptionsTabViewController loaded")
        
        self.fileManagerOptionsOrganizeController = self.childViewControllers[0] as! FileManagerOptionsOrganizeController
        
        self.fileManagerOptionsOrganizeController.fileBrowserViewController = self.fileBrowserViewController
      
        self.fileManagerOptionsMoveController = self.childViewControllers[1] as! FileManagerOptionsMoveController
        
        self.fileManagerOptionsCopyController = self.childViewControllers[2] as! FileManagerOptionsCopyController
        
        self.fileManagerOptionsRenameController = self.childViewControllers[3] as! FileManagerOptionsRenameController
        
        self.fileManagerOptionsDeleteController = self.childViewControllers[4] as! FileManagerOptionsDeleteController
        
        self.fileManagerOptionsOrganizeController.fileManagerOptionsTabViewController = self
        
        self.fileManagerOptionsCopyController.fileManagerOptionsTabViewController = self
        
        self.fileManagerOptionsMoveController.fileManagerOptionsTabViewController = self
        
//  self.fileManagerViewController = self.childViewControllers[3] as! FileManagerViewController

        
    }
    
}
