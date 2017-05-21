//
//  NewProjectController.swift
//  Drone Files
//
//  Created by Eric Rosebrock on 5/16/17.
//  Copyright © 2017 The Web Freaks, INC. All rights reserved.
//

import Foundation

import Cocoa

class NewProjectViewController: NSViewController {
    
    
    @IBOutlet var useSubDirectoriesCheckbox: ThemeCheckbox!
    @IBOutlet var useProjectDirectoryCheckbox: ThemeCheckbox!
    @IBOutlet var projectNameTextField: NSTextField!
    @IBOutlet var createProjectButton: ThemeButton!
    @IBOutlet var outputDirectoryButton: ThemeButton!
    @IBOutlet var outputDirectoryLabel: ThemeLabel!

    @IBOutlet var thumbnailDirectoryButton: ThemeButton!
    @IBOutlet var thumbnailDirectoryLabel: ThemeLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.projectNameTextField.resignFirstResponder()

        self.outputDirectoryLabel.stringValue = self.urlStringToDisplayPath(input: self.appSettings.outputDirectory)
        
        self.projectNameTextField.stringValue = self.appSettings.fileSequenceName
        if(self.appSettings.thumbnailDirectory != nil) {

            self.thumbnailDirectoryLabel.stringValue = self.urlStringToDisplayPath(input: self.appSettings.thumbnailDirectory)
        }
        
    }
    
    @IBAction func createProjectDirectoryCheckbox(_ sender: AnyObject?) {
        self.appDelegate.appSettings.createProjectDirectory = !self.appDelegate.appSettings.createProjectDirectory
        if(self.appDelegate.appSettings.createProjectDirectory) {
            UserDefaults.standard.setValue(1, forKey: "createProjectDirectory")
        } else {
            UserDefaults.standard.setValue(0, forKey: "createProjectDirectory")
        }
        
        // self.setupProjectDirectory()
        
        
    }
    
    @IBAction func createProjectSubDirectoriesCheckbox(_ sender: AnyObject?) {
        self.appDelegate.appSettings.createProjectSubDirectories = !self.appDelegate.appSettings.createProjectSubDirectories
        if(self.appSettings.createProjectSubDirectories) {
            UserDefaults.standard.setValue(1, forKey: "createProjectSubDirectories")
        } else {
            UserDefaults.standard.setValue(0, forKey: "createProjectSubDirectories")
        }
       //  self.setupProjectDirectory()
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
                self.thumbnailDirectoryLabel.stringValue = self.urlStringToDisplayPath(input: self.appDelegate.appSettings.thumbnailDirectory)
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
        
        self.appDelegate.fileBrowserViewController.writeProjectFile(projectPath: self.appDelegate.appSettings.projectFolder)
        
        self.view.window?.close()
        
    }

    
    @IBAction func cancel(sender: AnyObject) {
        
        
        self.view.window?.close()
        
    }

    
    
    
}
