//
//  NewProjectController.swift
//  Drone Files
//
//  Created by Eric Rosebrock on 5/16/17.
//  Copyright © 2017 The Web Freaks, INC. All rights reserved.
//

import Foundation

import Cocoa

class NewProjectWindowController: NSWindowController {
    override var windowNibName: String? {
        return "NewProjectWindow" // no extension .xib here
    }
}

class NewProjectWindow: NSWindow {
    @IBOutlet weak var toolBar: NSToolbar!
}


class NewProjectViewController: NSViewController {
    
    @IBOutlet var window: NSWindow!
    @IBOutlet var useSubDirectoriesCheckbox: ThemeCheckbox!
    @IBOutlet var useProjectDirectoryCheckbox: ThemeCheckbox!
    @IBOutlet var projectNameTextField: NSTextField!
    @IBOutlet var createProjectButton: ThemeButton!
    @IBOutlet var outputDirectoryButton: ThemeButton!
    @IBOutlet var outputDirectoryLabel: ThemeLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // self.projectNameTextField.resignFirstResponder()
        
        self.outputDirectoryLabel.stringValue = self.urlStringToDisplayPath(input: self.appSettings.outputDirectory)
        
        self.projectNameTextField.stringValue = self.appSettings.fileSequenceName

        self.view.wantsLayer = true
        
        self.view.layer?.backgroundColor = self.appSettings.appViewBackgroundColor.cgColor
        
        self.window?.titleVisibility = NSWindowTitleVisibility.hidden
        self.window.backgroundColor = self.appSettings.tableRowActiveBackGroundColor

        
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        self.window?.titleVisibility = NSWindowTitleVisibility.hidden
        self.window.backgroundColor = self.appSettings.tableRowActiveBackGroundColor
        self.window?.orderFront(self.view.window)
        self.window?.becomeFirstResponder()
        self.window?.titlebarAppearsTransparent = true

    
        self.projectNameTextField.becomeFirstResponder()

    }
    
    @IBAction func createProjectDirectoryCheckbox(_ sender: AnyObject?) {
        self.appDelegate.appSettings.createProjectDirectory = !self.appDelegate.appSettings.createProjectDirectory
        if(self.appDelegate.appSettings.createProjectDirectory) {
            UserDefaults.standard.setValue(1, forKey: "createProjectDirectory")
        } else {
            UserDefaults.standard.setValue(0, forKey: "createProjectDirectory")
        }
    }
    
    @IBAction func createProjectSubDirectoriesCheckbox(_ sender: AnyObject?) {
        self.appDelegate.appSettings.createProjectSubDirectories = !self.appDelegate.appSettings.createProjectSubDirectories
        if(self.appSettings.createProjectSubDirectories) {
            UserDefaults.standard.setValue(1, forKey: "createProjectSubDirectories")
        } else {
            UserDefaults.standard.setValue(0, forKey: "createProjectSubDirectories")
        }
    }
    
    
    
    // Open directory for tableview
    @IBAction func chooseOutputDirectory(_ sender: AnyObject?) {
        let openPanel = NSOpenPanel()
        openPanel.showsHiddenFiles = false
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = true
        openPanel.resolvesAliases = true
        
        openPanel.begin(completionHandler: {(result:Int) in
            if(result == NSFileHandlingPanelOKButton) {
                self.appDelegate.appSettings.outputDirectory = (openPanel.url?.absoluteString)!
                self.outputDirectoryLabel.stringValue = self.urlStringToDisplayPath(input: self.appDelegate.appSettings.outputDirectory)
                UserDefaults.standard.setValue(self.appDelegate.appSettings.outputDirectory, forKey: "outputDirectory")
                // self.setupProjectDirectory()
            }
            
        })
    }
    
    
    
    // Open directory for tableview
    @IBAction func chooseThumbnailDirectory(_ sender: AnyObject?) {
        let openPanel = NSOpenPanel()
        openPanel.showsHiddenFiles = false
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = true
        openPanel.resolvesAliases = true
        
        openPanel.begin(completionHandler: {(result:Int) in
            if(result == NSFileHandlingPanelOKButton) {
                self.appDelegate.appSettings.thumbnailDirectory = (openPanel.url?.absoluteString)!
                //self.thumbnailDirectoryLabel.stringValue = self.urlStringToDisplayPath(input: self.appDelegate.appSettings.thumbnailDirectory)
                // UserDefaults.standard.setValue(self.appDelegate.appSettings.thumbnailDirectory, forKey: "thumbnailDirectory")
                // self.setupProjectDirectory()
            }
            
        })
    }
    
    
    @IBAction func createNewProject(sender: AnyObject) {
        // self.projectNameTextField.resignFirstResponder()
        
        self.appDelegate.appSettings.fileSequenceName = self.projectNameTextField.stringValue
        
        // self.newFileNamePath.stringValue = self.fileSequenceName
        
        print("New Sequence Name \( self.appDelegate.appSettings.fileSequenceName)")
        
        UserDefaults.standard.setValue(self.appDelegate.appSettings.fileSequenceName, forKey: "fileSequenceNameTag")
        
        self.appDelegate.fileBrowserViewController.setupProjectDirectory()
        
        self.appDelegate.appSettings.mediaBinUrls.removeAll(keepingCapacity: false)
        
        self.appDelegate.appSettings.favoriteUrls.removeAll(keepingCapacity: false)
        
        self.appDelegate.writeProjectFile(projectPath: self.appDelegate.appSettings.projectFolder,loadNewFile: true)

        self.view.window?.close()
        
    }
    
    
    @IBAction func cancel(sender: AnyObject) {
        
        
        self.view.window?.close()
        
    }
    
    
    
    
}
