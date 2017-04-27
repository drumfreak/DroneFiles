//
//  FileManagerOptionsRenameController.swift
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


class FileManagerOptionsRenameController: NSViewController {
    
    @IBOutlet weak var fileBrowserViewController: FileBrowserViewController!
    @IBOutlet weak var fileManagerViewController: FileManagerViewController!
    @IBOutlet  var fileManagerOptionsTabViewController: FileManagerOptionsTabViewController!
    
    
    @IBOutlet var numberofFilesLabel: NSButton!
    @IBOutlet var renameSequenceLabel: NSTextField!
    @IBOutlet var organizeFilesButton: NSButton!
    
    var organizeFilesToFolder = false
    
    var renameSequenceName = ""
    
    var viewIsLoaded = false
    
    var receivedFiles = NSMutableArray() {
        didSet {
            //  print("Received Files on COPY Controller \(receivedFiles)")
            if(self.viewIsLoaded) {
                let count = String(format: "%2d", self.receivedFiles.count)
                self.numberofFilesLabel.title = count
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.viewIsLoaded = true
        let count = String(format: "%2d", self.receivedFiles.count)
        self.numberofFilesLabel.title = count
        
        if(UserDefaults.standard.value(forKey: "renameSequenceName") == nil) {
            self.renameSequenceName = self.fileManagerOptionsTabViewController.fileBrowserViewController.fileSequenceName
            UserDefaults.standard.setValue(self.renameSequenceName, forKey: "renameSequenceName")
        } else {
            self.renameSequenceName = UserDefaults.standard.value(forKey: "renameSequenceName") as! String
        }
        
        
        if(UserDefaults.standard.value(forKey: "organizeFilesToFolder") == nil) {
            UserDefaults.standard.setValue(self.organizeFilesToFolder, forKey: "organizeFilesToFolder")
        } else {
            self.organizeFilesToFolder = UserDefaults.standard.value(forKey: "organizeFilesToFolder") as! Bool
        }
        
        self.renameSequenceLabel.stringValue = self.renameSequenceName
        
        self.organizeFilesButton.state = (self.organizeFilesToFolder) ? 1 : 0
        
        
        
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.viewIsLoaded = false
    }
    
    func pathOutputFromURL(inputString: String) -> String {
        let str = inputString.replacingOccurrences(of: "file://", with: "").replacingOccurrences(of: "%20", with: " ")
        return str
    }
    
    @IBAction func setRenameSequence(_ sender: AnyObject) {
        self.renameSequenceName = self.renameSequenceLabel.stringValue
        UserDefaults.standard.setValue(self.renameSequenceName, forKey: "renameSequenceName")
    }
    
    @IBAction func organizeButtonClicked(_ sender: AnyObject) {
        self.organizeFilesToFolder = (self.organizeFilesButton.state == 1) ? true : false
        UserDefaults.standard.setValue(self.organizeFilesToFolder, forKey: "organizeFilesToFolder")
    }
    
    func fileOperationComplete(manageFileURLS: NSMutableArray, errors: Bool) {
        self.fileManagerOptionsTabViewController?.fileManagerViewController?.resetTableAfterFileOperation(fileArray: manageFileURLS)
        
        self.fileBrowserViewController?.reloadFilesWithSelected(fileName: "")
        if(!errors) {
            showAlert(text: "Files Moved!", body: "The files have been moved!", showCancel: false, messageType: "notice")
        }
    }
    
    
    @IBAction func renameFiles(_ sender: AnyObject) {
        let manageFileURLS: NSMutableArray = []
        let fileUrls = self.receivedFiles as! Array<Any>
        
        if(fileUrls.count > 0) {
            var errors = false
            
            // Dispatch this shit...
            DispatchQueue.global(qos: .userInitiated).async {
                fileUrls.forEach({ m in
                    let urlPath = m as! String
                    let url = URL(string: urlPath)
                    
                    if(self.renameTheFiles(url: url!)) {
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
    
    func renameTheFiles(url: URL) -> Bool {
        print("Renaming File! ... \(url)")
        
        // let tmpURL = NSURL(fileURLWithPath: url.absoluteString)
        let fileName = url.lastPathComponent
        let currentUrl = url.deletingLastPathComponent()
        
        let renameSequenceName = fileName /// FIX THIS
        print("Moving FROM filename: \(fileName)")
        
        var renameDestination = currentUrl.absoluteString + renameSequenceName
        
        //  copyDestination = getPathFromURL(path: copyDestination)
        renameDestination = renameDestination.replacingOccurrences(of: " ", with: "%20")
        
        print("RENAMING DESTINATION: \(renameDestination)")
        
        let destinationURL = URL(string: renameDestination)!
        
        if(self.doMoveFile(from: url, toUrl: destinationURL)) {
            print("Succes... file renamed")
            return true
        } else {
            print("File Rename Failed")
            return false
        }
    }
    
    func doMoveFile(from: URL, toUrl: URL) -> Bool {
        
        print("FROM: \(from)")
        print("TO: \(toUrl)")
        
        do {
            try FileManager.default.moveItem(at: from, to: toUrl)
            return true
        }
        catch _ as NSError {
            // print ("Error while moving file : \(from) to \(toUrl)")
            print("Ooops! Something went wrong: ")
            showAlert(text: "Could not move file", body:("This file " + from.absoluteString + " could not be moved"), showCancel: false, messageType: "warning")
            
            return false
        }
    }
    
    
    func getFileIncrementAtPath(path: String) -> String {
        var incrementer = "00"
        let Urlpath = path
        let path = getPathFromURL(path: path)
        
        if FileManager.default.fileExists(atPath: path) {
            do {
                let files = try FileManager.default.contentsOfDirectory(at: URL(string: Urlpath)!, includingPropertiesForKeys: nil, options: [])
                
                incrementer = String(format: "%02d", files.count)
                
            } catch let error as NSError {
                print(error.localizedDescription + "ok")
            }
        }
        return incrementer
    }
    
    func getPathFromURL(path: String) -> String {
        var path = path.replacingOccurrences(of: "file://", with: "")
        path = path.replacingOccurrences(of: "%20" , with: " ")
        return path
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
    
    func urlStringToDisplayURLString(input: String) -> String {
        return input.replacingOccurrences(of: "file://", with: "").replacingOccurrences(of: "%20", with: " ")
    }
    
    func urlStringToDisplayPath(input: String) -> String {
        return input.replacingOccurrences(of: "file://", with: "").replacingOccurrences(of: "%20", with: " ")
    }
    
    func setOpenPath1() {
        // doOpenFinder(urlString:self.moveToFolder)
    }
    
    func doOpenFinder(urlString: String) {
        let path = pathOutputFromURL(inputString: urlString)
        
        if FileManager.default.fileExists(atPath: path) {
            let url = URL(string: urlString)!
            
            NSWorkspace.shared().open(url)
        } else {
            showAlert(text: "That Folder Doesn't Exist", body: "Select a folder and try again.", showCancel: false, messageType: "warning")
        }
    }
    
}
