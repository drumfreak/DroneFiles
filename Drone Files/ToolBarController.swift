//
//  ToolBarController.swift
//  Drone Files
//
//  Created by Eric Rosebrock on 5/25/17.
//  Copyright © 2017 The Web Freaks, INC. All rights reserved.
//

import Cocoa
import Foundation

class ToolBarController: NSToolbar {
    @IBOutlet weak var newProjectItem: NSToolbarItem?
    @IBOutlet weak var projectNameTextField: NSTextField!
    @IBOutlet weak var newProjectButton: NSButton!
    @IBOutlet weak var loadProjectButton: NSButton!
    @IBOutlet weak var importFromCameraButton: NSButton!

    var newProjectWindowController: NewProjectWindowController!
    var secondWindowController: SecondWindowController!
    var mediaQueueMonitorWindowController: MediaQueueMonitorWindowController!

    
    override init(identifier: String) {
        super.init(identifier: identifier)
        
    }
    
 
    @IBAction func openNewProjectWindow(sender : AnyObject) {
        self.newProjectWindowController = NewProjectWindowController()
        self.newProjectWindowController.window?.makeKeyAndOrderFront(self)
    }
    
    
    // Open directory for tableview
    @IBAction func openProjectFile(_ sender: AnyObject?) {
        let openPanel = NSOpenPanel()
        openPanel.showsHiddenFiles = true
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = false
        openPanel.resolvesAliases = true
        openPanel.begin(completionHandler: {(result:Int) in
            if(result == NSFileHandlingPanelOKButton) {
                //print("Path Extension \(String(describing: openPanel.url?.pathExtension))")
                
                if(openPanel.url?.pathExtension == "dronefiles") {
                    //print ("HEY it's drone files!")
                    self.appDelegate.readProjectFile(projectFile: (openPanel.url?.absoluteString)!)
                    
                    self.appDelegate.fileBrowserViewController?.setupProjectDirectory()
                    
                    self.appDelegate.fileBrowserViewController?.sourceFolderOpened = URL(string: self.appSettings.projectDirectory)
        
                }
            }
            
        })
    }
    

    @IBAction func showVideoEditorTab(_ sender: AnyObject?) {
        if(!self.appDelegate.appSettings.videoSplitViewIsOpen) {
            self.appDelegate.rightPanelSplitViewController.showVideoSplitView()
        }
    }
    
    @IBAction func showImageEditorTab(_ sender: AnyObject?) {
        if(!self.appDelegate.appSettings.imageEditorSplitViewIsOpen) {
            self.appDelegate.rightPanelSplitViewController.showImageEditorSplitView()
        }
    }
    
    @IBAction func showFileManagerTab(_ sender: AnyObject?) {
        if(!self.appDelegate.appSettings.fileManagerSplitViewIsOpen) {
            self.appDelegate.rightPanelSplitViewController.showFileManagerSplitView()
        }
        
    }
    
    @IBAction func showSecondDisplayTab(_ sender: AnyObject?) {
        if(self.appDelegate.appSettings.secondDisplayIsOpen == false) {
            self.secondWindowController = SecondWindowController()
            self.secondWindowController?.showWindow(self)
        } else {
             self.appDelegate.secondaryDisplayMediaViewController?.view.window?.close()
        }
        
    }
    
    @IBAction func toggleMediaBin(_ sender: AnyObject?) {
        self.appDelegate.mediaBinCollectionView.hideScreenshotSlider(self)
    }
    
    @IBAction func toggleFileBrowser(_ sender: AnyObject?) {
        //print("File manager toolbar item clicked.")
        self.appDelegate.fileBrowserViewController.hideFileBrowser(self)
    }
    
    
    
    @IBAction func toggleMediaQueue(_ sender: AnyObject?) {
        if(!self.appDelegate.appSettings.mediaQueueIsOpen) {
            self.mediaQueueMonitorWindowController = MediaQueueMonitorWindowController()
            self.mediaQueueMonitorWindowController?.showWindow(self)
        } else {
            self.appDelegate.mediaQueueMonitorViewController?.view.window?.close()
        }
        
    }
    
}




class ThemeToolBarItem: NSToolbarItem {
}



