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
    @IBOutlet var numberofFilesLabel: NSButton!
    @IBOutlet var renameSequenceLabel: NSTextField!
    @IBOutlet var organizeFilesButton: NSButton!
    
    var organizeFilesToFolder = false
    
    var renameSequenceName = "" {
        didSet {
            UserDefaults.standard.setValue(self.renameSequenceName, forKey: "renameSequenceName")
        }
    }
    
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
            self.renameSequenceName = self.appDelegate.fileBrowserViewController.fileSequenceName
            // UserDefaults.standard.setValue(self.renameSequenceName, forKey: "renameSequenceName")
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
        // self.renameSequenceName = self.renameSequenceLabel.stringValue.trim()
        // UserDefaults.standard.setValue(self.renameSequenceName, forKey: "renameSequenceName")
        if(self.receivedFiles.count > 0) {
            let thisFilePath = self.receivedFiles[0] as! String
            let url = URL(string: thisFilePath)
            let thisFileName = url?.lastPathComponent
            let fileExtension = url?.pathExtension
            self.renameSequenceName = (thisFileName?.replacingOccurrences(of: ("." + fileExtension!), with: ""))!
            self.renameSequenceLabel.stringValue = self.renameSequenceName
        }
    }
    
    @IBAction func organizeButtonClicked(_ sender: AnyObject) {
        self.organizeFilesToFolder = (self.organizeFilesButton.state == 1) ? true : false
        UserDefaults.standard.setValue(self.organizeFilesToFolder, forKey: "organizeFilesToFolder")
    }
    
    
    func fileOperationComplete(manageFileURLS: NSMutableArray, errors: Bool) {
        self.appDelegate.fileManagerViewController?.resetTableAfterFileOperation(fileArray: manageFileURLS)
        
        self.appDelegate.fileBrowserViewController?.reloadFilesWithSelected(fileName: "")
        if(!errors) {
            showAlert(text: "Files Renamed!", body: "The files have been renamed!", showCancel: false, messageType: "notice")
        }
    }
    
    
    @IBAction func renameFiles(_ sender: AnyObject) {
        let manageFileURLS: NSMutableArray = []
        let fileUrls = self.receivedFiles as! Array<Any>
        
        
        if(fileUrls.count == 0) {
            showAlert(text: "No Files Selected!", body: "Select files from the File Manager List and try again.", showCancel: false, messageType: "warning")
            return
        }
        
        if(fileUrls.count == 1) {
            var errors = false
            self.renameSequenceName = self.renameSequenceLabel.stringValue.trim()
            // Rename 1 file to exactly the name of the input
            let thisFilePath = fileUrls[0] as! String
            let url = URL(string: thisFilePath)
            let thisPath = url?.deletingLastPathComponent()
            let newName = self.renameSequenceName
            let fileExtension = url?.pathExtension
            var folderPath = thisPath?.absoluteString
            
            // IS IT GOING INTO A DIRECTORY?
            if(self.organizeFilesToFolder) {
                folderPath = (thisPath?.absoluteString)! + newName + "/"
            }
            
            if(checkFolderAndCreate(folderPath: folderPath!.replacingOccurrences(of: " " , with: "%20"))) {
                var newFilePath = folderPath! + newName + "." + fileExtension!
                newFilePath = newFilePath.replacingOccurrences(of: " " , with: "%20")
                newFilePath = checkFileAndRename(filePath: newFilePath)
                let newFile = URL(string: newFilePath)
                
//                print("New File: ")
//                print(newFilePath)
                
                DispatchQueue.global(qos: .userInitiated).async {
                    if(self.renameSingleFiles(from: url!, to: newFile!)) {
                        manageFileURLS.add(url!)
                    } else {
                        errors = true
                    }
                    
                    DispatchQueue.main.async {
                        self.fileOperationComplete(manageFileURLS: manageFileURLS, errors: errors)
                    }
                }
                
            } else {
                showAlert(text: "Could not create directory", body:"Check your permissions and settings", showCancel: false, messageType: "warning")
            }
        }
        
        if(fileUrls.count > 1) {
            var errors = false
            
            self.renameSequenceName = self.renameSequenceLabel.stringValue.trim()
            // Rename 1 file to exactly the name of the input
            let thisFilePath = fileUrls[0] as! String
            let url = URL(string: thisFilePath)
            let thisPath = url?.deletingLastPathComponent()
            var folderPath = thisPath?.absoluteString
            
            let newName = self.renameSequenceName
            var fileExtension = url?.pathExtension
            
            // IS IT GOING INTO A DIRECTORY?
            if(self.organizeFilesToFolder) {
                folderPath = (thisPath?.absoluteString)! + newName + "/"
            }
            
            if(checkFolderAndCreate(folderPath: folderPath!.replacingOccurrences(of: " " , with: "%20"))) {

                DispatchQueue.global(qos: .userInitiated).async {
                    var i = 1
                    var incrementer = ""
                    
                    fileUrls.forEach({ m in
                        let urlPath = m as! String
                        let url = URL(string: urlPath)
                        fileExtension = url?.pathExtension

                       incrementer = String(format: "%02d", i)

                        var newFilePath = folderPath! + newName + " - " + incrementer + "." + fileExtension!
                        newFilePath = newFilePath.replacingOccurrences(of: " " , with: "%20")
                        newFilePath = self.checkFileAndRename(filePath: newFilePath)
                        let newFile = URL(string: newFilePath)
                        
                        i += 1
                        
                        if(self.renameSingleFiles(from: url!, to: newFile!)) {
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
                showAlert(text: "Could not create directory", body:"Check your permissions and settings", showCancel: false, messageType: "warning")
            }
            
        }
    }
    
    
    func checkFileAndRename (filePath: String!) -> String {
        let path = getPathFromURL(path: filePath)
        var pathExists = false
        let url = URL(string: filePath)
        let thisPath = url?.deletingLastPathComponent()
        let newName = self.renameSequenceName
        let fileExtension = url?.pathExtension
        let folderPath = thisPath?.absoluteString
        var newFilePath = ""
        // var newFile = URL(string:path)
        
        if FileManager.default.fileExists(atPath: path) {
            do {
                pathExists = true
                var i = 1
                while(pathExists) {
                    var incrementer = ""
                    incrementer = String(format: "%02d", i)
                    
                    newFilePath = folderPath! + newName + " - " + incrementer + "." + fileExtension!
                    newFilePath = newFilePath.replacingOccurrences(of: " " , with: "%20")
                    
                    let checkPath = getPathFromURL(path: newFilePath)
                    
                    if FileManager.default.fileExists(atPath: checkPath) {
                        i += 1
                    } else {
                        pathExists = false
                    }
                }
                return newFilePath
            }
        } else {
            return filePath
        }
    }
    
    func checkFolderAndCreate(folderPath: String) -> Bool {
        do {
            try FileManager.default.createDirectory(at: URL(string: folderPath)!, withIntermediateDirectories: true, attributes: nil)
            // print("Created Directory... " + folderPath)
            return true
        } catch _ as NSError {
            print("Error while creating a folder.")
            return false
        }
    }
    
    
    func renameSingleFiles(from: URL, to: URL) -> Bool {
        // print("Renaming File! ... \(from)")
        if(self.doMoveFile(from: from, toUrl: to)) {
            // print("Succes... file renamed")
            return true
        } else {
            // print("File Rename Failed")
            return false
        }
    }
    
    
    func renameTheFiles(url: URL) -> Bool {
        // print("Renaming File! ... \(url)")
        
        // let tmpURL = NSURL(fileURLWithPath: url.absoluteString)
        let fileName = url.lastPathComponent
        let currentUrl = url.deletingLastPathComponent()
        
        let renameSequenceName = fileName /// FIX THIS
        //print("Moving FROM filename: \(fileName)")
        
        var renameDestination = currentUrl.absoluteString + renameSequenceName
        
        //  copyDestination = getPathFromURL(path: copyDestination)
        renameDestination = renameDestination.replacingOccurrences(of: " ", with: "%20")
        
        // print("RENAMING DESTINATION: \(renameDestination)")
        
        let destinationURL = URL(string: renameDestination)!
        
        if(self.doMoveFile(from: url, toUrl: destinationURL)) {
            //print("Succes... file renamed")
            return true
        } else {
            //print("File Rename Failed")
            return false
        }
    }
    
    func doMoveFile(from: URL, toUrl: URL) -> Bool {
        
        //print("FROM: \(from)")
        // print("TO: \(toUrl)")
        
        do {
            try FileManager.default.moveItem(at: from, to: toUrl)
            return true
        }
        catch _ as NSError {
            // print ("Error while moving file : \(from) to \(toUrl)")
            print("Ooops! Something went wrong: ")
            DispatchQueue.main.async {
                self.showAlert(text: "Could not rename file", body:("This file " + from.absoluteString + " could not be renamed"), showCancel: false, messageType: "warning")
            }
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
