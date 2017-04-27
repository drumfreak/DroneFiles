//
//  FileManagerOptionsDeleteController.swift
//  Drone Files
//
//  Created by Eric Rosebrock on 4/25/17.
//  Copyright © 2017 The Web Freaks, INC. All rights reserved.
//

import Foundation
import Cocoa
import AVKit
import AppKit
import AVFoundation


class FileManagerOptionsDeleteController: NSViewController {
    
    @IBOutlet var numberofFilesLabel: NSButton!
    @IBOutlet var confirmDeleteButton: NSButton!
    
    var viewIsLoaded = false
    var receivedFiles = NSMutableArray() {
        didSet {
            //  print("Received Files on COPY Controller \(receivedFiles)")
            if(self.viewIsLoaded) {
                let count = String(format: "%", receivedFiles.count)
                self.numberofFilesLabel.title = count
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // print("FileManagerOptionsDeleteController loaded")
        
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.viewIsLoaded = true
        let count = String(format: "%1d", receivedFiles.count)
        self.numberofFilesLabel.title = count
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.viewIsLoaded = false
    }
    
    
    func fileOperationComplete(manageFileURLS: NSMutableArray, errors: Bool) {
        self.appDelegate.fileManagerViewController?.resetTableAfterFileOperation(fileArray: manageFileURLS)
        
        self.appDelegate.fileBrowserViewController?.reloadFilesWithSelected(fileName: "")
        if(!errors) {
            showAlert(text: "Files Deleted!", body: "The files have been Deleted!", showCancel: false, messageType: "notice")
        }
    }
    
    
    @IBAction func deleteFilesButtonClicked(_ sender: AnyObject) {
        let manageFileURLS: NSMutableArray = []
        let fileUrls = self.receivedFiles as! Array<Any>
        
        if(fileUrls.count > 0) {
            var errors = false
            DispatchQueue.global(qos: .userInitiated).async {
                fileUrls.forEach({ m in
                    let urlPath = m as! String
                    let url = URL(string: urlPath)
                    
                    if(self.deleteFile(url: url!)) {
                        manageFileURLS.add(url!)
                    } else {
                        errors = true
                    }
                })
                DispatchQueue.main.async {
                    self.fileOperationComplete(manageFileURLS: manageFileURLS, errors: errors)
                }
            }
            
            
        } else {
            showAlert(text: "No Files Selected!", body: "Select files from the File Manager List and try again.", showCancel: false, messageType: "warning")
        }
    }
    
    func deleteFile(url: URL) -> Bool {
        print("Moving File! ... \(url)")
        
        // let tmpURL = NSURL(fileURLWithPath: url.absoluteString)
        let fileName = url.lastPathComponent
        
        print("Deleting FROM filename: \(fileName)")

        
        if(self.doDeleteFile(from: url)) {
            print("Succes... file moved")
            return true
        } else {
            print("File Move Failed")
            return false
        }
    }
    
    func doDeleteFile(from: URL) -> Bool {
        
        print("FROM: \(from)")
        
        do {
            try FileManager.default.removeItem(at: from)
            return true
        }
        catch _ as NSError {
            // print ("Error while moving file : \(from) to \(toUrl)")
            print("Ooops! Something went wrong: ")
            DispatchQueue.main.async {
                self.showAlert(text: "Could not delete file", body:("This file " + from.absoluteString.replacingOccurrences(of: "%20", with: " ") + " could not be deleted"), showCancel: false, messageType: "warning")
            }
            
            return false
        }
    }

    func showAlert(text: String, body: String, showCancel: Bool, messageType: String) {
        let myPopup: NSAlert = NSAlert()
        myPopup.messageText = text
        myPopup.informativeText = body
        myPopup.alertStyle = NSAlertStyle.warning
        myPopup.addButton(withTitle: "OK")
        if(showCancel) {
            myPopup.addButton(withTitle: "Cancel")
        }
        myPopup.runModal()
    }

    
    
    
    
}
