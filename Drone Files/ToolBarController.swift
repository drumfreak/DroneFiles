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
                print("Path Extension \(String(describing: openPanel.url?.pathExtension))")
                
                if(openPanel.url?.pathExtension == "dronefiles") {
                    print ("HEY it's drone files!")
                    self.appDelegate.readProjectFile(projectFile: (openPanel.url?.absoluteString)!)
                    
                    self.appDelegate.fileBrowserViewController?.setupProjectDirectory()
                    self.appDelegate.fileBrowserViewController?.sourceFolderOpened = URL(string: self.appSettings.projectDirectory)
        
                }
            }
            
        })
    }
    
    
    
    
    @IBAction func showVideoEditorTab(_ sender: AnyObject?) {
        
        if(self.appDelegate.editorTabViewController?.selectedTabViewItemIndex != 0) {
            
                self.appDelegate.editorTabViewController?.selectedTabViewItemIndex  = 0
        
            }
    }
    

    
    @IBAction func showImageEditorTab(_ sender: AnyObject?) {
        
        if(self.appDelegate.editorTabViewController?.selectedTabViewItemIndex != 1) {
            
            self.appDelegate.editorTabViewController?.selectedTabViewItemIndex  = 1
            
        }
    }
    
    @IBAction func showFileManagerTab(_ sender: AnyObject?) {
        if(self.appDelegate.editorTabViewController?.selectedTabViewItemIndex != 2) {
            
            self.appDelegate.editorTabViewController?.selectedTabViewItemIndex  = 2
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
    
}




class ThemeToolBarItem: NSToolbarItem {

    // view = self.app
    // required override init(itemIdentifier: String) {
        
        
    // }
}



