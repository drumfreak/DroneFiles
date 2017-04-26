//
//  FileManagerOptionsOrganizeController.swift
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


class FileManagerOptionsOrganizeController: NSViewController {
    @IBOutlet  var fileBrowserViewController: FileBrowserViewController!
    @IBOutlet  var fileManagerViewController: FileManagerViewController!
    @IBOutlet  var fileManagerOptionsTabViewController: FileManagerOptionsTabViewController!

    @IBOutlet var projectDirectoryLabel: NSTextField!
    @IBOutlet var videosDirectoryLabel: NSTextField!
    @IBOutlet var jpgDirectoryLabel: NSTextField!
    @IBOutlet var rawDirectoryLabel: NSTextField!
    @IBOutlet var screenshotDirectoryLabel: NSTextField!

    @IBOutlet var numberofFilesLabel: NSTextField!
    
    var receivedFiles = NSMutableArray() {
        didSet {
            // print("Received Files on Organize Controller \(receivedFiles)"
            let count = String(format: "%02d", receivedFiles.count)
            self.numberofFilesLabel.stringValue = "(" + count  + ")"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // print("FileManagerOptionsOrganizeController loaded")
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        let projectPath = pathOutputFromURL(inputString: self.fileBrowserViewController.projectFolder)
        
        self.projectDirectoryLabel.stringValue = pathOutputFromURL(inputString: self.fileBrowserViewController.projectFolder)
        
        self.videosDirectoryLabel.stringValue = pathOutputFromURL(inputString: self.fileBrowserViewController.videoFolder).replacingOccurrences(of: projectPath, with: "")
        
        self.jpgDirectoryLabel.stringValue = pathOutputFromURL(inputString: self.fileBrowserViewController.jpgFolder).replacingOccurrences(of: projectPath, with: "")
        
        self.rawDirectoryLabel.stringValue = pathOutputFromURL(inputString: self.fileBrowserViewController.rawFolder).replacingOccurrences(of: projectPath, with: "")
        
        self.screenshotDirectoryLabel.stringValue = pathOutputFromURL(inputString: self.fileBrowserViewController.screenShotFolder).replacingOccurrences(of: projectPath, with: "")
    }
    
    func pathOutputFromURL(inputString: String) -> String {
        let str = inputString.replacingOccurrences(of: "file://", with: "").replacingOccurrences(of: "%20", with: " ")
        return str
    }
    
    
    @IBAction func organizeFiles(_ sender: AnyObject) {
        let manageFileURLS: NSMutableArray = []
        let manageFileMovies: NSMutableArray = []
        let manageFileScreenshots: NSMutableArray = []
        let manageFileJPG: NSMutableArray = []
        let manageFileRAW: NSMutableArray = []
        let manageFileOther: NSMutableArray = []
        
        let fileUrls = self.receivedFiles as! Array<Any>
        
        // print("SELECTED ITEMS \(item.url)")
        if(fileUrls.count > 0) {
            fileUrls.forEach({ m in
    
                let urlPath = m as! String
                let url = NSURL(fileURLWithPath: urlPath)
                let _extension = url.pathExtension
                var skip = false
                
                // item.index = index
                
                if(_extension == "MOV" || _extension == "mov" || _extension == "mp4" || _extension == "MP4" || _extension == "m4v" || _extension == "M4V") {
                    manageFileMovies.add(URL(string: urlPath)!)
                    skip = true
                }
                
                if(_extension == "JPG" || _extension == "jpg" || _extension == "jpeg" || _extension == "JPEG") {
                    manageFileJPG.add(URL(string: urlPath)!)
                    skip = true
                }
                
                if(_extension == "DNG" || _extension == "dng" ||  _extension == "RAW" ||  _extension == "raw") {
                    manageFileJPG.add(URL(string: urlPath)!)
                    skip = true
                }
                
                if(_extension == "png" || _extension == "PNG") {
                    manageFileScreenshots.add(URL(string: urlPath)!)
                    skip = true
                }
                
                if(!skip) {
                    manageFileOther.add(URL(string: urlPath)!)
                }
            })
            
            
            if(manageFileMovies.count > 0) {
                if(checkFolderAndCreate(folderPath: self.fileBrowserViewController.videoFolder)) {
                    print("VIDEOS FOLDER: \(self.fileBrowserViewController.videoFolder)")
                    manageFileMovies.forEach({ m in
                        let url = (m as! URL)
                        //print(movie)
                        if(self.organizeMovieFile(url: url)) {
                            manageFileURLS.add(url)
                        }
                    })
                }
            }
            
            if(manageFileJPG.count > 0) {
                if(checkFolderAndCreate(folderPath: self.fileBrowserViewController.jpgFolder)) {
                    manageFileJPG.forEach({ m in
                        let url = (m as! URL)
                        if(self.organizeJPGFile(url: url)) {
                            manageFileURLS.add(url)
                        }
                    })
                }
            }
            
            if(manageFileScreenshots.count > 0) {
                if(checkFolderAndCreate(folderPath: self.fileBrowserViewController.screenShotFolder)) {
                    manageFileScreenshots.forEach({ m in
                        let url = (m as! URL)


                        if(self.organizeScreenShotFile(url: (url))) {
                            manageFileURLS.add(url)
                        }
                    })
                }
            }
            
            if(manageFileRAW.count > 0) {
                if(checkFolderAndCreate(folderPath: self.fileBrowserViewController.rawFolder)) {
                    manageFileRAW.forEach({ m in
                        let url = (m as! URL)
                        if(self.organizeRawFile(url: (url))) {
                            manageFileURLS.add(url)
                        }
                    })
                }
            }
            
           self.fileManagerOptionsTabViewController?.fileManagerViewController?.resetTableAfterFileOperation(fileArray: manageFileURLS)
            
            //showNotification(messageType: "OrganizeFiles", customMessage: "No Files Selected!")
            showAlert(text: "Files Organized!", body: "The files have been organized!", showCancel: false, messageType: "warning")
            
            // showNotification(messageType: "OrganizeFiles", customMessage: self.fileBrowserViewController.videoFolder)
            
        } else {
            //showNotification(messageType: "OrganizeFiles", customMessage: "No Files Selected!")
            showAlert(text: "No Files Selected!", body: "Select files from the File Manager List and try again.", showCancel: false, messageType: "warning")
        }
    }
    
    func organizeMovieFile(url: URL) -> Bool {
        print("Organizing MOVIE ... \(url)")
        let increment =  getFileIncrementAtPath(path: self.fileBrowserViewController.videoFolder)
        
        var newMovieFile = self.fileBrowserViewController.videoFolder + "/" + self.fileBrowserViewController.fileSequenceName + " - " + increment + ".MOV" // for now
        
        newMovieFile = newMovieFile.replacingOccurrences(of: " ", with: "%20")
        if(self.moveFile(from: url, toUrl: URL(string: newMovieFile)!)) {
            print("Succes... file moved")
            return true
        } else {
            print("File Move Failed")
            return false
        }
        
    }
    
    func organizeJPGFile(url: URL) -> Bool  {
        print("Organizing JPG ... \(url)")
        
        let increment =  getFileIncrementAtPath(path: self.fileBrowserViewController.jpgFolder)
        
        var newJPGFile = self.fileBrowserViewController.jpgFolder + "/" + self.fileBrowserViewController.fileSequenceName + " - " + increment + ".jpg" // for now
        
        newJPGFile = newJPGFile.replacingOccurrences(of: " ", with: "%20")
        if(self.moveFile(from: url, toUrl: URL(string: newJPGFile)!)) {
            print("Succes... file moved")
            return true
        } else {
            print("File Move Failed")
            return false
        }
        
    }
    
    func organizeScreenShotFile(url: URL) -> Bool {
        print("Organizing Screenshot ... \(url)")
        
        let increment =  getFileIncrementAtPath(path: self.fileBrowserViewController.screenShotFolder)
        
        var newScreenshotFile = self.fileBrowserViewController.screenShotFolder + "/" + self.fileBrowserViewController.fileSequenceName + " - " + increment + ".png" // for now
        
        newScreenshotFile = newScreenshotFile.replacingOccurrences(of: " ", with: "%20")
        if(self.moveFile(from: url, toUrl: URL(string: newScreenshotFile)!)) {
            print("Succes... file moved");
            return true
        } else {
            print("File Move Failed")
            return false
        }
        
    }
    
    func organizeRawFile(url: URL) -> Bool {
        print("Organizing RAW ... \(url)")
        
        let increment =  getFileIncrementAtPath(path: self.fileBrowserViewController.screenShotFolder)
        
        var newRawFile = self.fileBrowserViewController.screenShotFolder + "/" + self.fileBrowserViewController.fileSequenceName + " - " + increment + ".dng" // for now
        
        newRawFile = newRawFile.replacingOccurrences(of: " ", with: "%20")
        if(self.moveFile(from: url, toUrl: URL(string: newRawFile)!)) {
            print("Succes... file moved")
            return true
        } else {
            print("File Move Failed")
            return false
        }
        
    }
    
    
    func organizeOtherFile(url: URL) -> Bool {
        print("Organizing Other ... \(url)")
        return false
    }
    
    func moveFile(from: URL, toUrl: URL) -> Bool {
        // print ("Moving file : \(from) to \(toUrl)")
        
        do {
            try FileManager.default.moveItem(at: from, to: toUrl)
            return true
        }
        catch let error as NSError {
            // print ("Error while moving file : \(from) to \(toUrl)")
            print("Ooops! Something went wrong: \(error)")
            
            showAlert(text: "Could not move file", body:("This file " + from.absoluteString + " could not be moved"), showCancel: false, messageType: "warning")
            
            return false
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
    
    
    
    
}
