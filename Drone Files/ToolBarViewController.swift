//
//  ToolBarViewController.swift
//  Drone Files
//
//  Created by Eric Rosebrock on 5/24/17.
//  Copyright © 2017 The Web Freaks, INC. All rights reserved.
//

import Cocoa

class ToolBarViewController: NSViewController {

    @IBOutlet weak var projectNameTextField: NSTextField!
    @IBOutlet weak var newProjectButton: NSButton!
    @IBOutlet weak var loadProjectButton: NSButton!
    @IBOutlet weak var importFromCameraButton: NSButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    
        
        DispatchQueue.main.async {
            // self.statusLabel.stringValue = "0 Items Selected"
            self.projectNameTextField.stringValue = self.appDelegate.appSettings.fileSequenceName
            
            self.appDelegate.appSettings.saveDirectoryName = self.appDelegate.appSettings.fileSequenceName
        }

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
                    
                    
                    //                    self.appDelegate.documentController.openDocument(withContentsOf: openPanel.url!, display: true, completionHandler: { (document: NSDocument?, wasOpen: Bool, err: Error?) in
                    //                        print("Fuck yeah \(String(describing: document))")
                    //                        print("Error: \(String(describing: err))")
                    //                    })
                    
                }
            }
            
        })
    }
    
    
    
    
    @IBAction func showVideoEditorTab(_ sender: AnyObject?) {

    
    }
    
    
    @IBAction func showImageEditorTab(_ sender: AnyObject?) {
        
        
    }
    
    @IBAction func showFileManagerTab(_ sender: AnyObject?) {
        
        
    }
    
    @IBAction func sshowSecondDisplayTab(_ sender: AnyObject?) {
        
        
    }
    
}
